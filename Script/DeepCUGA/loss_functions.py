# -*- coding: utf-8 -*-

import torch
import torch.nn as nn
import torch.nn.functional as F

class FocalLoss(nn.Module):
    """
    Support multi-class weight configuration.
    Loss(x, class) = - \alpha (1-softmax(x)[class])^gamma \log(softmax(x)[class])
    """

    def __init__(self, class_num, alpha=None, gamma=2, size_average=True):
        super(FocalLoss, self).__init__()
        self.gamma = gamma
        self.class_num = class_num
        self.size_average = size_average

        if alpha is None:
            alpha = torch.ones(class_num)
        else:
            if not isinstance(alpha, torch.Tensor):
                alpha = torch.tensor(alpha, dtype=torch.float32)
        self.register_buffer('alpha', alpha.view(-1, 1))

    def forward(self, inputs, targets):
        """
        inputs: [N, C] (logits)
        targets: [N] label
        """
        N = inputs.size(0)
        C = inputs.size(1)

        P = F.softmax(inputs, dim=1)

        class_mask = torch.zeros((N, C), device=inputs.device)
        ids = targets.view(-1, 1)
        class_mask.scatter_(1, ids, 1.0)

        alpha_weights = self.alpha[ids.view(-1)]

        probs = (P * class_mask).sum(1).view(-1, 1)

        log_p = probs.clamp(min=1e-12).log()

        batch_loss = -alpha_weights * (torch.pow((1 - probs), self.gamma)) * log_p

        if self.size_average:
            return batch_loss.mean()
        else:
            return batch_loss.sum()