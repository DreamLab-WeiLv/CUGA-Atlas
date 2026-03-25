# -*- coding: utf-8 -*-

from __future__ import print_function

import argparse
import torch.optim.lr_scheduler as lr_scheduler
from torch.utils.data import DataLoader
from torch.utils.tensorboard import SummaryWriter
import matplotlib
import matplotlib.pyplot as plt
from sklearn.model_selection import StratifiedGroupKFold
from scipy import stats
import pandas as pd
import csv

# from sklearn.metrics import confusion_matrix
from core_utils_cuga import *
from utils import *
from dataset import *
from TransMILCUGA import TransCUGA
from early_stopping import EarlyStopping

def setup_seed(seed):
    """Set random seed for reproducibility."""
    torch.manual_seed(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

def initialize_metrics(num_folds, num_classes):
    """Initialize arrays to store metrics for each fold."""
    metrics = {
        'best_acc': np.zeros(num_folds),
        'best_auc_mean': np.zeros(num_folds),
        'best_pre': np.zeros(num_folds),
        'best_spe': np.zeros(num_folds),
        'best_recall': np.zeros(num_folds),
        'best_f1': np.zeros(num_folds),
        'best_ppv': np.zeros(num_folds),
        'best_npv': np.zeros(num_folds),

        'best_acc_train': np.zeros(num_folds),
        'best_auc_mean_train': np.zeros(num_folds),
        'best_pre_train': np.zeros(num_folds),
        'best_spe_train': np.zeros(num_folds),
        'best_recall_train': np.zeros(num_folds),
        'best_f1_train': np.zeros(num_folds),
        'best_ppv_train': np.zeros(num_folds),
        'best_npv_train': np.zeros(num_folds),

    }
    if num_classes == 2:
        metrics['best_auc'] = np.zeros(num_folds)
        metrics['best_auc_train'] = np.zeros(num_folds)
    else:
        metrics['best_auc_arrays'] = {f'best_auc_{i}_fold': np.zeros(num_classes) for i in range(num_folds)}
        metrics['best_auc_arrays_train'] = {f'best_auc_train_{i}_fold': np.zeros(num_classes) for i in range(num_folds)}
    return metrics

def save_predictions(results_dir, fold, loader, y_true, y_pred, split='val'):
    """Save predictions for each fold to CSV."""
    sample_names = [loader.dataset[i][3] for i in range(len(loader.dataset))]
    predictions_df = pd.DataFrame({
        'Sample Name': sample_names,
        'True Label': y_true,
        'Predicted Label': y_pred
    })
    predictions_df.to_csv(f'{results_dir}/prediction_training_{split}_loader_fold_{fold}.csv', index=False)

def plot_confusion_matrix(y_true, y_pred, label_map, results_dir, fold, split='val', dpi=800, font_size=12):
    """Plot and save confusion matrix."""
    plt.rcParams['figure.dpi'] = dpi
    matplotlib.rcParams['font.size'] = font_size

    cm = confusion_matrix(y_true, y_pred)

    plt.figure()
    # plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Reds)
    plt.colorbar()

    tick_marks = np.arange(len(label_map))
    keys = list(label_map.keys())
    # plt.xticks(tick_marks, keys)
    # plt.yticks(tick_marks, keys)

    plt.xticks(tick_marks, keys, rotation=45, ha='right', rotation_mode='anchor')
    plt.yticks(tick_marks, keys, rotation=45, va='center', rotation_mode='anchor')

    row_sums = cm.sum(axis=1)
    for j in range(len(cm)):
        for k in range(len(cm)):
            if row_sums[j] > 0:
                percentage = cm[j, k] / row_sums[j] * 100
            else:
                percentage = 0
            background_color = plt.cm.Blues(cm[j, k] / cm.max())
            brightness = 0.299 * background_color[0] + 0.587 * background_color[1] + 0.114 * background_color[2]
            text_color = "white" if brightness < 0.5 else "black"
            plt.annotate(f'{cm[j, k]}\n({percentage:.1f}%)', xy=(k, j),
                         horizontalalignment='center', verticalalignment='center',
                         color=text_color)

    plt.xlabel('Predicted')
    plt.ylabel('Reported')
    plt.title(f'Confusion Matrix - {split.capitalize()} Set')
    plt.savefig(f'{results_dir}/best_auc_confusion_matrix_{split}_fold_{fold}.png',dpi=dpi, bbox_inches='tight')
    plt.close()


def plot_auroc_curves(args, fpr, tpr, aucs, label_map, mean_fpr, mean_tpr_placeholder, results_dir, fold, num_classes,
                      split='val'):
    """Plot and save AUROC curves for multi-class."""
    plt.rcParams['figure.dpi'] = 800
    matplotlib.rcParams['font.size'] = 12
    lw = 2
    keys = list(label_map.keys())
    color_list = ['#FDDED7', '#F5BE8F', '#C1E0DB', '#CCD376', '#A28CC2', 'red']

    current_tpr = []

    for idx in range(num_classes):
        plt.plot(fpr[idx], tpr[idx], color=color_list[idx], lw=lw,
                 label=f'{keys[idx]} (AUC: {aucs[idx]:.3f})')

        interp_tpr = np.interp(mean_fpr[idx], fpr[idx], tpr[idx])
        interp_tpr[0] = 0.0
        current_tpr.append(interp_tpr)

    plt.plot([0, 1], [0, 1], color='gray', lw=lw, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title(f'AUROC Curve - {split.capitalize()} Set')
    plt.legend(loc="lower right")
    plt.savefig(f'{results_dir}/auroc_mean_{split}_fold_{fold}.png')
    plt.close()

    return current_tpr  #


def save_results(args, results_dir, metrics, label_map, mean_fpr, mean_tpr, mean_fpr_train, mean_tpr_train, num_folds, num_classes):
    """Save final results to CSV and plot average AUROC for multi-class for both validation and training sets."""

    # =========================================
    for idx in range(num_classes):
        mean_tpr[idx] /= num_folds
        mean_tpr_train[idx] /= num_folds
    # ==========================================

    if num_classes == 2:
        with open(f'{results_dir}/prediction_matrix_results.csv', 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['fold', 'auc', 'acc', 'precision', 'specificity', 'recall', 'f1', 'ppv', 'npv'])
            for i in range(num_folds):
                writer.writerow([i, metrics['best_auc'][i], metrics['best_acc'][i],
                                metrics['best_pre'][i], metrics['best_spe'][i],
                                metrics['best_recall'][i], metrics['best_f1'][i],
                                metrics['best_ppv'][i], metrics['best_npv'][i]])
    else:
        classes_names = ['AMP', 'CIN', 'GS', 'LOH', 'LOH-early']
        column_names = [f"auc_{classes_names[i]}" for i in range(num_classes)]
        column_names.insert(0, 'fold')
        column_names += ['mean_max_auc', 'best_auc_mean', 'acc', 'Precision', 'Specificity', 'Recall', 'F1 score', 'PPV', 'NPV']

        with open(f'{results_dir}/prediction_matrix_results.csv', 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(column_names)
            for i in range(num_folds):
                row = [i] + list(metrics['best_auc_arrays'][f'best_auc_{i}_fold'])
                row += [sum(metrics['best_auc_arrays'][f'best_auc_{i}_fold']) / num_classes,
                        metrics['best_auc_mean'][i], metrics['best_acc'][i],
                        metrics['best_pre'][i], metrics['best_spe'][i],
                        metrics['best_recall'][i], metrics['best_f1'][i],
                        metrics['best_ppv'][i], metrics['best_npv'][i]]
                writer.writerow(row)

    # save training matrix
    if num_classes == 2:
        with open(f'{results_dir}/prediction_matrix_results_train.csv', 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['fold', 'auc', 'acc', 'precision', 'specificity', 'recall', 'f1', 'ppv', 'npv'])
            for i in range(num_folds):
                writer.writerow([i, metrics['best_auc_train'][i], metrics['best_acc_train'][i],
                                 metrics['best_pre_train'][i], metrics['best_spe_train'][i],
                                 metrics['best_recall_train'][i], metrics['best_f1_train'][i],
                                 metrics['best_ppv_train'][i], metrics['best_npv_train'][i]])
    else:
        classes_names = ['AMP', 'CIN', 'GS', 'LOH', 'LOH-early']
        column_names_train = [f"auc_{classes_names[i]}" for i in range(num_classes)]
        column_names_train.insert(0, 'fold')
        column_names_train += ['mean_max_auc', 'best_auc_mean', 'acc', 'Precision', 'Specificity', 'Recall','F1 score', 'PPV', 'NPV']

        with open(f'{results_dir}/prediction_matrix_results_train.csv', 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(column_names_train)
            for i in range(num_folds):
                row = [i] + list(metrics['best_auc_arrays_train'][f'best_auc_train_{i}_fold'])
                row += [sum(metrics['best_auc_arrays_train'][f'best_auc_train_{i}_fold']) / num_classes,
                        metrics['best_auc_mean_train'][i], metrics['best_acc_train'][i],
                        metrics['best_pre_train'][i], metrics['best_spe_train'][i],
                        metrics['best_recall_train'][i], metrics['best_f1_train'][i],
                        metrics['best_ppv_train'][i], metrics['best_npv_train'][i]]
                writer.writerow(row)


        # Plot validation set average AUROC
        lw = 2
        keys = list(label_map.keys())
        mean_max_auc_per_class = [np.mean([metrics['best_auc_arrays'][f'best_auc_{i}_fold'][j] for i in range(num_folds)])
                                  for j in range(num_classes)]
        for j in range(num_classes):
            # plt.plot(mean_fpr[j], mean_tpr[j], color=['#E71D36', '#FF9F1C', '#2EC4B6'][j], linestyle='--', lw=lw,
            #          label=f'{keys[j]} (AUC: {mean_max_auc_per_class[j]:.3f})')

            plt.plot(mean_fpr[j], mean_tpr[j], color=['#FDDED7', '#F5BE8F', '#C1E0DB', '#CCD376', '#A28CC2'][j], linestyle='--', lw=lw,
                     label=f'{keys[j]} (AUC: {mean_max_auc_per_class[j]:.3f})')
            # color_list = ['#FDDED7', '#F5BE8F', '#C1E0DB', '#CCD376', '#A28CC2','red']
        mean_fpr_avg = np.mean(mean_fpr, axis=0)
        mean_tpr_avg = np.mean(mean_tpr, axis=0)
        global_mean_max_auc = np.mean(mean_max_auc_per_class)
        std_auc = np.std(mean_max_auc_per_class)
        confidence_interval = stats.t.interval(0.95, num_folds - 1, loc=global_mean_max_auc,
                                              scale=std_auc / np.sqrt(num_folds))
        ci_lower, ci_upper = confidence_interval

        # saved as .npy files
        val_auroc_metrics = {
            'mean_fpr': mean_fpr,
            'mean_tpr': mean_tpr,
            'mean_fpr_avg': mean_fpr_avg,
            'mean_tpr_avg': mean_tpr_avg,
            'mean_max_auc_per_class': mean_max_auc_per_class,
            'global_mean_max_auc': global_mean_max_auc,
            'ci_lower': ci_lower,
            'ci_upper': ci_upper,
            'label_map': label_map
        }
        np.save(f'{results_dir}/val_auroc_metrics.npy', val_auroc_metrics)


        plt.plot(mean_fpr_avg, mean_tpr_avg, color='red', lw=lw,  #color='#000000' ---> black
                 label=f'Macro-average (AUC: {global_mean_max_auc:.3f}, \n95% CI: {ci_lower:.3f} - {ci_upper:.3f})')

        plt.plot([0, 1], [0, 1], color='gray', lw=lw, linestyle='--')
        plt.xlim([0.0, 1.0])
        plt.ylim([0.0, 1.05])
        plt.xlabel('False Positive Rate')
        plt.ylabel('True Positive Rate')
        plt.title('AUROC Curve -  Validation Set')
        plt.legend(loc="lower right")
        plt.savefig(f'{results_dir}/auroc_mean_fold_mean.png')
        plt.close()

        # Plot training set average AUROC
        plt.rcParams['figure.dpi'] = 800
        matplotlib.rcParams['font.size'] = 12
        mean_max_auc_per_class_train = [np.mean([metrics['best_auc_arrays_train'][f'best_auc_train_{i}_fold'][j] for i in range(num_folds)])
                                        for j in range(num_classes)]
        for j in range(num_classes):
            plt.plot(mean_fpr_train[j], mean_tpr_train[j], color=['#FDDED7', '#F5BE8F', '#C1E0DB', '#CCD376', '#A28CC2'][j], linestyle='--', lw=lw,
                     label=f'{keys[j]} (AUC: {mean_max_auc_per_class_train[j]:.3f})')  # 5 classes

        mean_fpr_train_avg = np.mean(mean_fpr_train, axis=0)
        mean_tpr_train_avg = np.mean(mean_tpr_train, axis=0)
        global_mean_max_auc_train = np.mean(mean_max_auc_per_class_train)
        std_auc_train = np.std(mean_max_auc_per_class_train)
        confidence_interval_train = stats.t.interval(0.95, num_folds - 1, loc=global_mean_max_auc_train,
                                                    scale=std_auc_train / np.sqrt(num_folds))
        ci_lower_train, ci_upper_train = confidence_interval_train

        #
        train_auroc_metrics = {
            'mean_fpr': mean_fpr_train,
            'mean_tpr': mean_tpr_train,
            'mean_fpr_avg': mean_fpr_train_avg,
            'mean_tpr_avg': mean_tpr_train_avg,
            'mean_max_auc_per_class': mean_max_auc_per_class_train,
            'global_mean_max_auc': global_mean_max_auc_train,
            'ci_lower': ci_lower_train,
            'ci_upper': ci_upper_train,
            'label_map': label_map
        }
        np.save(f'{results_dir}/train_auroc_metrics.npy', train_auroc_metrics)

        plt.plot(mean_fpr_train_avg, mean_tpr_train_avg, color='red', lw=lw,  #color='#000000' ---> black
                 label=f'Macro-average (AUC: {global_mean_max_auc_train:.3f}, \n95% CI: {ci_lower_train:.3f} - {ci_upper_train:.3f})')

        plt.plot([0, 1], [0, 1], color='gray', lw=lw, linestyle='--')
        plt.xlim([0.0, 1.0])
        plt.ylim([0.0, 1.05])
        plt.xlabel('False Positive Rate')
        plt.ylabel('True Positive Rate')
        plt.title('AUROC Curve - Training Set')
        plt.legend(loc="lower right")
        plt.savefig(f'{results_dir}/auroc_mean_fold_mean_train.png')
        plt.close()


def load_multi_task_labels(csv_dir):
    """
    lode MTL labels
    """
    # 1. laod csv file
    main_df = pd.read_csv(os.path.join(csv_dir, 'CUGA-Subtype-5classes.csv'))

    subtype_map = {
        'AMP': 0,
        'CIN': 1,
        'GS': 2,
        'LOH': 3,
        'LOH-early': 4
    }

    # mapping
    if main_df['label'].dtype == object:
        main_df['label'] = main_df['label'].map(subtype_map)

    # 3. Define the name of the sub-event
    event_names = ['WGD', 'Chromothripsis', 'ecDNA', 'TP53', 'FGFR3']


    # 4. Merge the CSVS of the other five events
    for event in event_names:
        event_path = os.path.join(csv_dir, f'CUGA-Subtype-{event}.csv')
        if os.path.exists(event_path):
            event_df = pd.read_csv(event_path)[['slide_id', 'label']]
            event_df = event_df.rename(columns={'label': f'label_{event}'})
            main_df = pd.merge(main_df, event_df, on='slide_id', how='left')
        else:
            print(f"Warning: {event_path} not found, filling with 0")
            main_df[f'label_{event}'] = 0

    main_df = main_df.fillna(0)

    # 5. Extract the label column
    label_cols = ['label'] + [f'label_{e}' for e in event_names]

    try:
        all_labels = main_df[label_cols].values.astype(int)
    except ValueError as e:
        print("Error during label conversion. Current label columns contain non-numeric data:")
        for col in label_cols:
            unique_vals = main_df[col].unique()
            print(f"Column '{col}' unique values: {unique_vals}")
        raise e

    return main_df, all_labels


def main(args):
    setup_seed(args.seed)
    device = torch.device(args.device if torch.cuda.is_available() else "cpu")

    mean_fpr = [np.linspace(0, 1, 10000) for _ in range(args.num_classes)]
    mean_tpr = [np.zeros_like(fpr) for fpr in mean_fpr]
    mean_fpr_train = [np.linspace(0, 1, 10000) for _ in range(args.num_classes)]
    mean_tpr_train = [np.zeros_like(fpr) for fpr in mean_fpr_train]

    os.makedirs(args.results_dir, exist_ok=True)

    csv_dir = os.path.dirname(args.csv_file)
    df, all_labels = load_multi_task_labels(csv_dir)
    # print(f"Sample labels (first 5):\n{all_labels[:5]}")  #

    df['slide_path'] = args.features_path + df['slide_id'] + '.h5'

    label_map = {0: 'AMP', 1: 'CIN', 2: 'GS', 3: 'LOH', 4: 'LOH-early'}
    print(f"Label mapping: {label_map}")

    metrics = initialize_metrics(args.num_folds, args.num_classes)

    gskf = StratifiedGroupKFold(n_splits=args.num_folds, shuffle=True, random_state=args.seed)
    groups = df['case_id']

    # --- loop section ---
    for fold, (train_idx, val_idx) in enumerate(gskf.split(df, df['label'], groups)):
        print(f"Experiment Fold {fold + 1}")

        slide_train = df.loc[train_idx, 'slide_path'].tolist()
        label_train = all_labels[train_idx]  #

        slide_val = df.loc[val_idx, 'slide_path'].tolist()
        label_val = all_labels[val_idx]  #

        print(f'Total {len(slide_train)} slides for training')
        print(f'Total {len(slide_val)} slides for validation')
        print('--' * 50)

        weights_dir = f'{args.results_dir}/weights_{fold}'
        os.makedirs(weights_dir, exist_ok=True)

        SWriter = SummaryWriter(log_dir=f'{args.results_dir}/fold_{fold}')

        train_data = get_bag_feats(args=args, fts_path=slide_train, fts_label=label_train)
        val_data = get_bag_feats(args=args, fts_path=slide_val, fts_label=label_val)

        train_loader = DataLoader(
            dataset=train_data, batch_size=args.batch_size, shuffle=True,
            num_workers=2, collate_fn=collate_MIL, pin_memory=True, drop_last=False)
        val_loader = DataLoader(
            dataset=val_data, batch_size=args.batch_size, shuffle=False,
            num_workers=2, collate_fn=collate_MIL, pin_memory=True, drop_last=True)

        model = TransCUGA(n_classes=args.num_classes).to(device)
        optimizer = torch.optim.Adam(model.parameters(), lr=args.lr, weight_decay=1e-3)
        lf = lambda x: ((1 + np.cos(x * np.pi / args.epochs)) / 2) * (1 - args.lrf) + args.lrf
        scheduler = lr_scheduler.LambdaLR(optimizer, lr_lambda=lf)

        early_stopping = EarlyStopping(args.patience, verbose=True)

        best_metrics = {
            'auc': 0.0 if args.num_classes == 2 else {f'best_auc_{j}': 0.0 for j in range(args.num_classes)},
            'acc': 0.0, 'pre': 0.0, 'spe': 0.0, 'recall': 0.0, 'f1': 0.0, 'ppv': 0.0, 'npv': 0.0}
        best_auc_mean_this_fold = 0.0

        for epoch in range(args.epochs):

            mean_loss = train(args, model=model, optimizer=optimizer, data_loader=train_loader, device=device)
            scheduler.step()

            # Validation set: Set 'search_alpha=True' to obtain the 'best_alpha' from grid search.
            acc, auc, mean_loss_val, y_true, y_pred, aucs, fpr, tpr, precision, specificity, recall, f1, ppv, npv, atten_scores, best_alpha = evaluate(
                args, model=model, data_loader=val_loader, device=device, search_alpha=True
            )

            save_predictions(args.results_dir, fold, val_loader, y_true, y_pred, split='val')

            train_acc, train_auc, train_mean_loss, train_y_true, train_y_pred, train_aucs, train_fpr, train_tpr, train_precision, train_specificity, train_recall, train_f1, train_ppv, train_npv, _, _ = evaluate(
                args, model=model, data_loader=train_loader, device=device, search_alpha=False, fixed_alpha=best_alpha
            )

            save_predictions(args.results_dir, fold, train_loader, train_y_true, train_y_pred, split='train')

            is_best_auc = (args.num_classes == 2 and auc > best_metrics['auc']) or \
                          (args.num_classes > 2 and sum(aucs) / args.num_classes > best_auc_mean_this_fold)

            if is_best_auc:
                best_metrics['auc'] = auc if args.num_classes == 2 else {f'best_auc_{j}': aucs[j] for j in
                                                                         range(args.num_classes)}
                best_metrics.update({'acc': acc, 'pre': precision, 'spe': specificity, 'recall': recall,
                                     'f1': f1, 'ppv': ppv, 'npv': npv})
                best_auc_mean_this_fold = sum(aucs) / args.num_classes if args.num_classes > 2 else auc

                if args.num_classes == 2:
                    metrics['best_auc'][fold] = auc
                else:
                    metrics['best_auc_arrays'][f'best_auc_{fold}_fold'] = aucs
                    metrics['best_auc_mean'][fold] = best_auc_mean_this_fold

                metrics['best_acc'][fold] = acc
                metrics['best_pre'][fold] = precision
                metrics['best_spe'][fold] = specificity
                metrics['best_recall'][fold] = recall
                metrics['best_f1'][fold] = f1
                metrics['best_ppv'][fold] = ppv
                metrics['best_npv'][fold] = npv

                if args.num_classes == 2:
                    metrics['best_auc_train'][fold] = train_auc
                else:
                    metrics['best_auc_arrays_train'][f'best_auc_train_{fold}_fold'] = train_aucs
                    metrics['best_auc_mean_train'][fold] = sum(train_aucs) / args.num_classes

                metrics['best_acc_train'][fold] = train_acc
                metrics['best_pre_train'][fold] = train_precision
                metrics['best_spe_train'][fold] = train_specificity
                metrics['best_recall_train'][fold] = train_recall
                metrics['best_f1_train'][fold] = train_f1
                metrics['best_ppv_train'][fold] = train_ppv
                metrics['best_npv_train'][fold] = train_npv

                #save checkpoint
                checkpoint = {
                    'model_state_dict': model.state_dict(),
                    'epoch': epoch,
                    'auc': auc if args.num_classes == 2 else sum(aucs) / args.num_classes,
                    'optimizer_state_dict': optimizer.state_dict(),
                }
                torch.save(checkpoint, f'{weights_dir}/best_auc_checkpoint.pth')
                torch.save(atten_scores, f'{args.results_dir}/atten_scores_fold_{fold}.pt')

                #confusion matrix
                plot_confusion_matrix(y_true, y_pred, label_map, args.results_dir, fold, split='val')
                plot_confusion_matrix(train_y_true, train_y_pred, label_map, args.results_dir, fold, split='train')

                best_val_tpr_this_fold = plot_auroc_curves(args, fpr, tpr, aucs, label_map, mean_fpr, mean_tpr,
                                                           args.results_dir, fold, args.num_classes, split='val')

                best_train_tpr_this_fold = plot_auroc_curves(args, train_fpr, train_tpr, train_aucs, label_map,
                                                             mean_fpr_train, mean_tpr_train,
                                                             args.results_dir, fold, args.num_classes, split='train')

            # Tensorboard
            print(f"[epoch {epoch}] accuracy: {acc:.3f} | mean_auc: {(sum(aucs) / args.num_classes) if args.num_classes > 2 else auc :.3f}")

            SWriter.add_scalar("loss/train", mean_loss, epoch)
            SWriter.add_scalar("loss/val", mean_loss_val, epoch)
            SWriter.add_scalar("accuracy/val", acc, epoch)
            SWriter.add_scalar("auc/val_mean", sum(aucs) / args.num_classes if args.num_classes > 2 else auc, epoch)
            SWriter.add_scalar("fusion/alpha", best_alpha, epoch)  # recording Alpha

            if epoch >= args.stop_start:
                # EarlyStopping
                early_stopping(mean_loss_val, model, fold, args.results_dir)
                if early_stopping.early_stop:
                    print('Early stopping')
                    break

        for idx in range(args.num_classes):
            mean_tpr[idx] += best_val_tpr_this_fold[idx]
            mean_tpr_train[idx] += best_train_tpr_this_fold[idx]

    save_results(args, args.results_dir, metrics, label_map, mean_fpr, mean_tpr, mean_fpr_train, mean_tpr_train,
                 args.num_folds, args.num_classes)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='DeepCUGA script')
    parser.add_argument('--seed', type=int, default=3407, help='random seed for reproducible experiment (default: 3407)')
    parser.add_argument('--num_classes', type=int, default=5, help='number of classes') #5 classes
    parser.add_argument('--lr', type=float, default=1e-5, help='learning rate (default: 0.0001)')
    parser.add_argument('--epochs', type=int, default=50, help='number of epochs')
    parser.add_argument('--device', default='cuda:0', help='device id (i.e. 0 or 0,1 or cpu)')
    parser.add_argument('--lrf', type=float, default=0.1, help='learning rate final ratio')
    parser.add_argument('--batch_size', type=int, default=1, help='batch size (default: 1)')
    parser.add_argument('--num_folds', type=int, default=5, help='number of folds (default: 5)')

    #-----------------------MTL setting--------------------------------------------------------------------------------------------
    parser.add_argument('--lambda_event', type=float, default=1.0, help='Weighting coefficient for genomic events loss')
    parser.add_argument('--csv_file', type=str,default=r'/path/CUGA-Subtype-5classes.csv',help='path to the main subtype csv file')
    parser.add_argument('--features_path', type=str, default=r'/path/h5_files/', help='CONCH-20X feats')
    parser.add_argument('--results_dir', type=str, default=r'/path/DeepCUGA/', help='results directory')

    parser.add_argument('--stop_start', type=int, default=5, help='epoch to start early stopping')
    parser.add_argument('--patience', type=int, default=15, help='max epochs to wait for improvement')
    parser.add_argument('--use_apex', type=bool, default=False, help='enable mixed precision training using NVIDIA Apex')
    parser.add_argument('--use_pos_embed', type=bool, default=False, help='enable positional embedding in the model')
    parser.add_argument('--WSI_path', type=str, default='/data/', help='path to whole slide images (WSIs)')
    parser.add_argument('--epoch_des', type=int, default=10, help='epoch to turn on neg pos discrimination')
    opt = parser.parse_args()

    main(opt)
