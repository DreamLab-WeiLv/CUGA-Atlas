# -*- coding: utf-8 -*-

import sys
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from tqdm import tqdm
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score, roc_curve, roc_auc_score
from sklearn.preprocessing import label_binarize
from loss_functions import FocalLoss

def train(args, model, optimizer, data_loader, device):
    model.train()

    weights = None
    if hasattr(args, 'weights') and args.weights is not None:
        weights = torch.tensor(args.weights, dtype=torch.float32).to(device)

    criterion_subtype = FocalLoss(class_num=args.num_classes, alpha=weights).to(device)
    criterion_event = nn.BCEWithLogitsLoss().to(device)

    optimizer.zero_grad()
    data_loader = tqdm(data_loader, file=sys.stdout)
    total_loss = 0

    # coefficient alpha and the event Loss weight lambda
    alpha = getattr(args, 'alpha', 1.0)
    lambda_event = getattr(args, 'lambda_event', 1.0)

    for step, data in enumerate(data_loader):
        images, labels, coords, _ = data
        images, labels = images.to(device), labels.to(device)

        results = model(images)

        # Jointly optimize the Subtype Loss of the two branches
        loss_path = criterion_subtype(results['logits_path'], labels[:, 0])
        loss_geno = criterion_subtype(results['logits_geno'], labels[:, 0])
        loss_subtype = alpha * loss_path + (1 - alpha) * loss_geno

        # 5 binary categorical events Losses
        loss_binary = sum([criterion_event(results['binary_events'][i], labels[:, i + 1].float().unsqueeze(1)) for i in range(5)]) / 5.0

        # L_total = L_subtype + lambda * L_event
        combined_loss = loss_subtype + lambda_event * loss_binary

        combined_loss.backward()
        optimizer.step()
        optimizer.zero_grad()

        total_loss += combined_loss.item()
        data_loader.desc = f"[Train] loss: {combined_loss.item():.4f}"

    return total_loss / len(data_loader)


@torch.no_grad()
def evaluate(args, model, data_loader, device, search_alpha=False, fixed_alpha=0.5):
    model.eval()

    y_tru = []
    logits_path_all, logits_geno_all = [], []
    atten_scores = []

    data_loader = tqdm(data_loader, file=sys.stdout)
    val_loss = 0.0

    weights = torch.tensor(args.weights, dtype=torch.float32).to(device) if hasattr(args, 'weights') else None
    criterion_subtype = FocalLoss(class_num=args.num_classes, alpha=weights).to(device)
    criterion_event = nn.BCEWithLogitsLoss().to(device)

    lambda_event = getattr(args, 'lambda_event', 1.0)

    for step, data in enumerate(data_loader):
        images, labels, coords, _ = data
        images, labels = images.to(device), labels.to(device)

        results = model(images)
        A = results['attention']

        # Loss
        loss_path = criterion_subtype(results['logits_path'], labels[:, 0])
        loss_geno = criterion_subtype(results['logits_geno'], labels[:, 0])
        loss_subtype = 0.5 * loss_path + 0.5 * loss_geno

        loss_binary = sum([criterion_event(results['binary_events'][i], labels[:, i + 1].float().unsqueeze(1)) for i in range(5)]) / 5.0
        current_loss = loss_subtype + lambda_event * loss_binary
        val_loss += current_loss.item()

        y_tru.extend(labels[:, 0].cpu().numpy())
        logits_path_all.append(results['logits_path'].cpu())
        logits_geno_all.append(results['logits_geno'].cpu())
        atten_scores.append(A.cpu())

    y_tru = np.array(y_tru)
    val_loss /= len(data_loader)

    # Convert the list to a tensor for matrix operations
    logits_path_tensor = torch.cat(logits_path_all, dim=0)
    logits_geno_tensor = torch.cat(logits_geno_all, dim=0)

    p_path = F.softmax(logits_path_tensor, dim=1).numpy()
    p_geno = F.softmax(logits_geno_tensor, dim=1).numpy()

    label_bin = label_binarize(y_tru, classes=list(range(args.num_classes)))

    # 2. Core logic: Grid Search seeks the best Alpha
    best_alpha = fixed_alpha
    if search_alpha:
        best_auc = -1
        # Conduct grid search with a step size of 0.1 between 0.0 and 1.0
        alphas_to_test = np.linspace(0.0, 1.0, 11)
        for a in alphas_to_test:
            p_final_temp = a * p_path + (1 - a) * p_geno
            # Calculate the macro average AUC
            try:
                auc_temp = roc_auc_score(label_bin, p_final_temp, multi_class='ovr', average='macro')
                if auc_temp > best_auc:
                    best_auc = auc_temp
                    best_alpha = a
            except ValueError:
                pass  #

    # 3. Calculate the final result using the determined best_alpha
    p_final = best_alpha * p_path + (1 - best_alpha) * p_geno
    y_pred = np.argmax(p_final, axis=1)
    y_prob = p_final

    # Calculate the final AUC
    auc_score = roc_auc_score(label_bin, y_prob, multi_class='ovr', average='macro')

    # Metrics
    cm = confusion_matrix(y_tru, y_pred)
    accuracy = np.sum(np.diag(cm)) / np.sum(cm) if np.sum(cm) > 0 else 0
    precision = precision_score(y_tru, y_pred, average='macro', zero_division=0)
    recall = recall_score(y_tru, y_pred, average='macro', zero_division=0)
    f1 = f1_score(y_tru, y_pred, average='macro', zero_division=0)

    spec_list, npv_list = [], []
    for c in range(args.num_classes):
        TP = cm[c, c] if c < len(cm) else 0
        TN = cm.sum() - cm[c, :].sum() - cm[:, c].sum() + TP if c < len(cm) else 0
        FP = cm[:, c].sum() - TP if c < len(cm) else 0
        FN = cm[c, :].sum() - TP if c < len(cm) else 0
        spec_list.append(TN / (TN + FP) if (TN + FP) > 0 else 0)
        npv_list.append(TN / (TN + FN) if (TN + FN) > 0 else 0)

    specificity = np.mean(spec_list)
    npv = np.mean(npv_list)

    fpr, tpr, aucs = [], [], []
    for i in range(args.num_classes):
        f, t, _ = roc_curve(label_bin[:, i], y_prob[:, i])
        fpr.append(f)
        tpr.append(t)
        aucs.append(roc_auc_score(label_bin[:, i], y_prob[:, i]))

    return (accuracy, auc_score, val_loss, y_tru, y_pred,
            aucs, fpr, tpr, precision, specificity,
            recall, f1, precision, npv, atten_scores, best_alpha)