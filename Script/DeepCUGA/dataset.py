# -*- coding: utf-8 -*-

import os
import h5py
import numpy as np
import torch
from torch.utils.data import Dataset
import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning)

class data_features(Dataset):
    def __init__(self, fts_path: list, fts_label: list):
        self.features_path = fts_path
        self.features_label = fts_label

    def __len__(self):
        return len(self.features_path)

    def __getitem__(self, idx):
        case_file = self.features_path[idx]
        # label: [Subtype, E1, E2, E3, E4, E5]
        label = self.features_label[idx]

        file = os.path.join(case_file)
        features = torch.load(file)

        return features, torch.tensor(label).long()


class get_bag_feats(Dataset):
    """
    The multi-instance Learning (MIL) data loading class supports reading features and coordinates from.h5 files.
    Enhanced for multi-task learning, it returns multi-dimensional labels.
    """

    def __init__(self, args, fts_path: list, fts_label: list):
        self.features_path = fts_path
        self.features_label = fts_label  #
        self.use_pos_embed = args.use_pos_embed
        self.WSI_path = args.WSI_path

    def __len__(self):
        return len(self.features_path)

    def __getitem__(self, idx):
        slide_file = self.features_path[idx]

        label = self.features_label[idx]

        if slide_file.endswith('.h5'):
            with h5py.File(slide_file, 'r') as file:
                features = torch.from_numpy(file['features'][:]).to(torch.float32)

                if self.use_pos_embed:
                    coords = file['coords'][:]

                    new_coord = np.zeros((coords.shape[0], 2))
                    new_coord[:, 0] = (coords[:, 0] + coords[:, 2]) / 2
                    new_coord[:, 1] = (coords[:, 1] + coords[:, 3]) / 2
                    coords = torch.from_numpy(new_coord).to(torch.float32)
                else:
                    coords = torch.zeros((features.shape[0], 2))

        elif slide_file.endswith('.pt'):
            features = torch.load(slide_file).to(torch.float32)
            coords = torch.zeros((features.shape[0], 2))

        else:
            raise ValueError(f"unsupported file format: {slide_file}")

        return features, torch.tensor(label).long(), coords, slide_file
