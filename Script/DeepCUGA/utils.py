# -*- coding: utf-8 -*-

import torch

def collate_MIL(batch):
    img = torch.stack([item[0] for item in batch], dim=0)  # [B, N, 512]
    # extract MTL label vector
    label = torch.stack([item[1] for item in batch], dim=0)
    # coords and paths
    coords = [item[2] for item in batch]
    paths = [item[3] for item in batch]

    return [img, label, coords, paths]