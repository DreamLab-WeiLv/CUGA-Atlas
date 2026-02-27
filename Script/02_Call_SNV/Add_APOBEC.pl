#!/usr/bin/perl -w
use strict;

my ($info,$in,$ot)=@ARGV;

my %hash;
open IN,"$info" or die $!;
while (<IN>){
	chomp;
	my ($index,$contexts)=(split /\t/)[0,-1];
#	my ($chr,$pos,$ref,$alt)=split /:/,$index;
	$hash{$index}=$contexts;
}
close IN;

if($ot=~/\.gz$/){open OT,"|gzip >$ot" or die $!;}else{open OT,">$ot" or die $!;}
if($in=~/\.gz$/){open IN,"gunzip -cd <$in|" or die $!;}else{open IN,"<$in" or die $!;}
while (<IN>){
	chomp;
	if ($.==1){
		print OT "$_\tcontexts\n";
		next;
	}
	my ($chr,$pos,$ref,$alt,$Variant_Type)=(split /\t/)[4,5,10,11,9];
	if ($Variant_Type eq "SNP"){
		my $index="$chr:$pos:$ref:$alt";
		print OT "$_\t$hash{$index}\n";
	}
	else {print OT "$_\t-\n";}
}
close IN;
close OT;
exit;
