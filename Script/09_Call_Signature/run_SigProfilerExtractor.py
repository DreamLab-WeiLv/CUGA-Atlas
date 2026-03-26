#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: mishugeb
"""
from SigProfilerExtractor import sigpro as sig
import SigProfilerExtractor as spe_mod
import os
import pandas as pd

def run_matrix_96():
    data = pd.read_csv("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/SBS/CUGA_all669.SBS96.all",sep="\t")
    sig.sigProfilerExtractor(
        "matrix",
        "CUGA669_SBS96_output",
        data,
	reference_genome="GRCh38",
        minimum_signatures=1,
        maximum_signatures=20,
        nmf_replicates=500,
        #min_nmf_iterations=100,
        #max_nmf_iterations=1000,
        #nmf_test_conv=100,
        opportunity_genome="GRCh38"
    )


def run_matrix_78():
    data = pd.read_csv("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/DBS/CUGA_all669.DBS78.all",sep="\t")
    sig.sigProfilerExtractor(
        "matrix",
        "CUGA669_DBS78_output",
        data,
        reference_genome="GRCh38",
        minimum_signatures=1,
        maximum_signatures=20,
        nmf_replicates=200,
        #min_nmf_iterations=100,
        #max_nmf_iterations=1000,
        #nmf_test_conv=100,
        opportunity_genome="GRCh38"
    )


def run_matrix_83():
    data = pd.read_csv("/share/home/luoylLab/zengyuchen/PROJECT/chromothripsis/Signature/input_vcf/all669/output/ID/CUGA_all669.ID83.all",sep="\t")
    sig.sigProfilerExtractor(
        "matrix",
        "CUGA669_ID83_output",
        data,
        exome=True,
        reference_genome="GRCh38",
        minimum_signatures=1,
        maximum_signatures=20,
        nmf_replicates=200,
        #min_nmf_iterations=100,
        #max_nmf_iterations=1000,
        #nmf_test_conv=100,
        opportunity_genome="GRCh38"
    )


def run_vcf():
    vcf_data = sig.importdata("vcf")
    sig.sigProfilerExtractor(
        "vcf",
        "test_vcf_output",
        vcf_data,
        minimum_signatures=10,
        maximum_signatures=50,
        nmf_replicates=1000,
        min_nmf_iterations=100,
        max_nmf_iterations=1000,
        nmf_test_conv=100,
    )


def run_matrix_48():
    data = sig.importdata("matrix_CNV")
    sig.sigProfilerExtractor(
        "matrix",
        "test_matrix_48_output",
        data,
        minimum_signatures=3,
        maximum_signatures=3,
        nmf_replicates=5,
        min_nmf_iterations=100,
        max_nmf_iterations=1000,
        nmf_test_conv=100,
    )


def run_seg_48():
    data = sig.importdata("seg:BATTENBERG")
    sig.sigProfilerExtractor(
        "seg:BATTENBERG",
        "test_segCNV_output",
        data,
        minimum_signatures=3,
        maximum_signatures=3,
        nmf_replicates=5,
        min_nmf_iterations=100,
        max_nmf_iterations=1000,
        nmf_test_conv=100,
    )


def run_matrix_32():
    data = sig.importdata("matrix_SV")
    sig.sigProfilerExtractor(
        "matrix",
        "test_matrix_32_output",
        data,
        minimum_signatures=3,
        maximum_signatures=3,
        nmf_replicates=5,
        min_nmf_iterations=100,
        max_nmf_iterations=1000,
        nmf_test_conv=100,
    )


def run_matobj():
    data = sig.importdata("matobj")
    sig.sigProfilerExtractor(
        "matobj",
        "test_matobj_output",
        data,
        minimum_signatures=3,
        maximum_signatures=3,
        nmf_replicates=5,
        min_nmf_iterations=100,
        max_nmf_iterations=1000,
        nmf_test_conv=100,
    )


def run_csv():
    data = sig.importdata("csv")
    sig.sigProfilerExtractor(
        "csv",
        "test_csv_output",
        data,
        minimum_signatures=3,
        maximum_signatures=3,
        nmf_replicates=5,
        min_nmf_iterations=100,
        max_nmf_iterations=1000,
        nmf_test_conv=100,
    )


if __name__ == "__main__":
    run_matrix_96()
    #run_matrix_78()
    #run_matrix_83()
    #run_matrix_48()
    #run_matrix_32()
    #run_seg_48()
    #run_vcf()
    # run_matobj()
    # run_csv()
