#!/usr/bin/perl -w
use strict;

my ($in,$ot,$exonic_region)=@ARGV;

$exonic_region ||="35792924";

my (%exonic,%NonSyn,%APOBEC);
my %sample;

if($in=~/\.gz$/){open IN,"gunzip -cd <$in|" or die $!;}else{open IN,"<$in" or die $!;}
while (<IN>){
	chomp;
	next if $.==1;
	my ($Variant_Classification,$Tumor_Sample_Barcode,$contexts)=(split /\t/)[8,12,16];
	$exonic{$Tumor_Sample_Barcode}++;
	$NonSyn{$Tumor_Sample_Barcode}++ unless ($Variant_Classification eq "Silent");
	$APOBEC{$Tumor_Sample_Barcode}++ if ($contexts eq "APOBEC");
	$sample{$Tumor_Sample_Barcode}="";
}
close IN;

open OT,">$ot" or die $!;
print OT "CaseID\tNo_exonic_Mutations\tTMB_exonic\tNo_NonSyn\tTMB_NonSyn\tNo_APOBEC\tTMB_APOBEC\n";
foreach my $sample(sort keys %sample){
	my $No_exonic_Mutations=$exonic{$sample};
	my $No_NonSyn=$NonSyn{$sample};
	my $No_APOBEC=$APOBEC{$sample};
	my $TMB_exonic = ($No_exonic_Mutations/$exonic_region)*1000000;
	my $TMB_NonSyn = ($No_NonSyn/$exonic_region)*1000000;
	my $TMB_APOBEC = ($No_APOBEC/$exonic_region)*1000000;
	print OT "$sample\t$No_exonic_Mutations\t$TMB_exonic\t$No_NonSyn\t$TMB_NonSyn\t$No_APOBEC\t$TMB_APOBEC\n";
}
close OT;
exit;
