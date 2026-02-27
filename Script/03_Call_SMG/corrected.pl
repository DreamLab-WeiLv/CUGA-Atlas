#!/usr/bin/perl -w
use strict;

my ($corrected,$in,$ot)=@ARGV;

my %corrected;
open IN,"$corrected" or die $!;
while (<IN>){
	# Hugo_Symbol (in MutSig)     OG_Hugo_Symbol
	# MLL3    KMT2C
	chomp;
	next if $.==1;
	my @t=split /\t/;
	$corrected{$t[1]}=$t[0];
}
close IN;

foreach my $k(sort keys %corrected){
	print "$k\t$corrected{$k}\t(Name_in_MutSig)\n" if ($k ne $corrected{$k});
}

if($in=~/\.gz$/){open IN,"gunzip -cd <$in|" or die $!;}else{open IN,"<$in" or die $!;}
if($ot=~/\.gz$/){open OT,"|gzip >$ot" or die $!;}else{open OT,">$ot" or die $!;}
while (<IN>){
	chomp;
	if ($.==1){print OT "$_\n";next;}
	my @t=split /\t/;
	my $others=join("\t",@t[2..@t-1]);
	if (exists $corrected{$t[0]}){
		my $new=$corrected{$t[0]};
		print OT "$new\t$new\t$others\n";
	}
	else {print "Not found: $_\n";}
}
close IN;
close OT;
exit;
