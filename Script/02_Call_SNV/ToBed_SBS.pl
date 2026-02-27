#!/usr/bin/perl -w
use strict;

my ($in,$bed)=@ARGV;

my %hash;
if($in=~/\.gz$/){open IN,"gunzip -cd <$in|" or die $!;}else{open IN,"<$in" or die $!;}
while (<IN>){
	chomp;
	next if $.==1;
	my @t=split /\t/;
	next unless $t[9] eq "SNP";
	my $start=$t[5]-1;
	my $end=$t[5]+1;
	my $index="$t[4]\t$start\t$end\t$t[10]-$t[11]\t$t[4]:$t[5]:$t[10]:$t[11]";
	$hash{$index}="";
}
close IN;

open OT,">$bed" or die $!;
foreach my $k(sort keys %hash){
	print OT "$k\n";
}
close OT;
exit;
