#!/usr/bin/perl -w
use strict;

my ($bed,$in,$ot)=@ARGV;

my %hash;
open IN,"$bed" or die $!;
while (<IN>){
	chomp;
	my @t=split /\t/;
#	chr1    22222414        22222415        GRCh38_chr1:21895921-21895921
	my $end=$t[2]-1;
	$hash{$t[-1]}="$t[0]\t$t[1]\t$end";
}
close IN;

if($in=~/\.gz$/){open IN,"gunzip -cd <$in|" or die $!;}else{open IN,"<$in" or die $!;}
if($ot=~/\.gz$/){open OT,"|gzip >$ot" or die $!;}else{open OT,">$ot" or die $!;}
while (<IN>){
	chomp;
	if ($.==1){print OT "$_\n";next;}
	my @t=split /\t/;
	my $index="$t[3]_$t[4]:$t[5]-$t[6]";
	my $others=join("\t",@t[7..@t-1]);
	if (exists $hash{$index}){
		print OT "$t[0]\t$t[1]\t$t[2]\thg19\t$hash{$index}\t$others\n";
	}
	else {print "$_\n";}
}
close IN;
close OT;
exit;
