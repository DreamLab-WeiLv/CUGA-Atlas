# -*- coding: utf-8 -*-

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
from nystrom_attention import NystromAttention

class TransLayer(nn.Module):
    def __init__(self, norm_layer=nn.LayerNorm, dim=512):
        super().__init__()
        self.norm = norm_layer(dim)
        self.attn = NystromAttention(
            dim=dim,
            dim_head=dim // 8,
            heads=8,
            num_landmarks=dim // 2,
            pinv_iterations=6,
            residual=True,
            dropout=0.25
        )

    def forward(self, x):
        x = x + self.attn(self.norm(x))
        return x


class PPEG(nn.Module):
    def __init__(self, dim=512):
        super(PPEG, self).__init__()
        self.proj = nn.Conv2d(dim, dim, 7, 1, 7 // 2, groups=dim)
        self.proj1 = nn.Conv2d(dim, dim, 5, 1, 5 // 2, groups=dim)
        self.proj2 = nn.Conv2d(dim, dim, 3, 1, 3 // 2, groups=dim)

    def forward(self, x, H, W):
        B, _, C = x.shape
        cls_token, feat_token = x[:, 0], x[:, 1:]
        cnn_feat = feat_token.transpose(1, 2).view(B, C, H, W)
        x = self.proj(cnn_feat) + cnn_feat + self.proj1(cnn_feat) + self.proj2(cnn_feat)
        x = x.flatten(2).transpose(1, 2)
        x = torch.cat((cls_token.unsqueeze(1), x), dim=1)
        return x

class TransCUGA(nn.Module):
    def __init__(self, n_classes):
        super(TransCUGA, self).__init__()
        self.n_classes = n_classes
        self.pos_layer = PPEG(dim=512)
        self._fc1 = nn.Sequential(nn.Linear(512, 512), nn.ReLU())
        self.cls_token = nn.Parameter(torch.randn(1, 1, 512))
        self.layer1 = TransLayer(dim=512)
        self.layer2 = TransLayer(dim=512)
        self.norm = nn.LayerNorm(512)

        # 5 event heads (WGD, Chromothripsis, ecDNA, TP53, FGFR3)
        self.binary_event_heads = nn.ModuleList([nn.Linear(512, 1) for _ in range(5)])

        # 1. Morphological-driven branch: Mapping directly from 512-dimensional Z_cls to subtypes
        self.morphology_head = nn.Linear(512, self.n_classes)

        # 2. Genome-driven branching: Receive the concatenated probability vector V_genomic (5 events * 1 probability = 5 dimensions)
        self.genotype_head = nn.Linear(5, self.n_classes)

    def forward(self, x):
        if x.dim() == 2:
            h = x.unsqueeze(0)
        else:
            h = x

        h = self._fc1(h)

        # ----> (padding)
        H_orig = h.shape[1]
        _H, _W = int(np.ceil(np.sqrt(H_orig))), int(np.ceil(np.sqrt(H_orig)))
        add_length = _H * _W - H_orig
        h = torch.cat([h, h[:, :add_length, :]], dim=1)

        # ---->  CLS token
        B = h.shape[0]
        cls_tokens = self.cls_token.expand(B, -1, -1)
        h = torch.cat((cls_tokens, h), dim=1)

        # ----> Through Transformer layers and position encoding
        h = self.layer1(h)
        h = self.pos_layer(h, _H, _W)
        h = self.layer2(h)

        # ----> Extract global classification features(cls_feat)
        h_norm = self.norm(h)
        cls_feat = h_norm[:, 0]  # [B, 512], #Z_cls
        patch_feats = h_norm[:, 1:]

        # ==========================================================
        # branch 1: Morphology-driven Subtype Inference
        # ==========================================================
        logits_path = self.morphology_head(cls_feat)

        # ==========================================================
        # branch 2: Genotype-informed Subtype Inference
        # ==========================================================
        # Calculate the Logits of five events
        logits_binary = [head(cls_feat) for head in self.binary_event_heads]

        probs_binary = [torch.sigmoid(l) for l in logits_binary]

        v_genomic = torch.cat(probs_binary, dim=1)

        # Map to genome-driven subtype prediction
        logits_geno = self.genotype_head(v_genomic)

        # ----> Calculate the attention score
        patch_feats_real = patch_feats[:, :H_orig, :]
        A = torch.einsum('bd,bnd->bn', cls_feat, patch_feats_real)
        A = torch.softmax(A, dim=-1)
        A = A.unsqueeze(1)  # [B, 1, N]

        # Return two Logits for the loss function calculation and the event Logits for the cross-entropy calculation
        results = {
            'logits_path': logits_path,
            'logits_geno': logits_geno,
            'binary_events': logits_binary,
            'attention': A
        }

        return results