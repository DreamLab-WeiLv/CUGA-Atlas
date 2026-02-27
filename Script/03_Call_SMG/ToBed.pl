#!/usr/bin/perl -w
use strict;

my ($in,$bed)=@ARGV;
if($in=~/\.gz$/){open IN,"gunzip -cd <$in|" or die $!;}else{open IN,"<$in" or die $!;}
open OT,">$bed" or die $!;
while (<IN>){
	chomp;
	next if $.==1;
	my @t=split /\t/;
	my $end=$t[6]+1;
	print OT "$t[4]\t$t[5]\t$end\t$t[3]_$t[4]:$t[5]-$t[6]\n";
}
close IN;
close OT;
exit;
