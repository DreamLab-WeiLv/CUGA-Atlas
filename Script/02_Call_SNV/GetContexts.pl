#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my ($ref,$bed,$ot)=@ARGV;

# C>A, C>G, C>T, T>A, T>C, and T>G

my %substitutions =(
	'C-A' => 'C>A',
	'G-T' => 'C>A',
	'C-G' => 'C>G',
	'G-C' => 'C>G',
	'C-T' => 'C>T',
	'G-A' => 'C>T',
	'T-A' => 'T>A',
	'A-T' => 'T>A',
	'T-C' => 'T>C',
	'A-G' => 'T>C',
	'T-G' => 'T>G',
	'A-C' => 'T>G');

my (%ref,$chr,%region);
if($ref=~/\.gz$/){open IN,"gunzip -cd <$ref|" or die $!;}else{open IN,"<$ref" or die $!;}
while (<IN>){
	chomp;
	if(/^>/){$chr =(split /\>|\s+/,$_)[1];}
	else{$ref{$chr}.=uc($_);}
}
close IN;

my $n=0;
open IN,"$bed" or die $!;
while (<IN>){
	chomp;
	$n++;
	my @t = split /\t/;
	die "Incorrect format of input bed!\n" unless ($t[0] =~/^chr/i and $t[1]=~/\d+/ and $t[2]=~/\d+/);
	next unless (exists $ref{$t[0]});
	push @{$region{$n}},[$t[0],$t[1],$t[2],$t[3],$t[4]];
}
close IN;

open OT,">$ot" or die $!;
foreach my $key (sort {$b <=> $a} keys %region){
	for(my $i = 0; $i < @{$region{$key}}; $i++){
		my $start = $region{$key}[$i][1] - 1;
		my $length =$region{$key}[$i][2]-$region{$key}[$i][1]+1;
		my $char = substr($ref{$region{$key}[$i][0]}, $start, $length);
#		print OT ">$region{$key}[$i][0]:$region{$key}[$i][1]-$region{$key}[$i][2]\n$char\n";
		my $sbs=$region{$key}[$i][3];
		my $substitutions=$substitutions{$sbs};
		my $contexts=$char;
		if ($sbs!~/^C|T/){
			$contexts=reverse $contexts;
			$contexts=~tr/ACGTacgt/TGCAtgca/;
		}
		my $motif="-";
		$motif="tCw" if $contexts=~/TCA|TCT/;
		my $type="-";
		$type="APOBEC" if ($motif eq "tCw" and $substitutions=~/C>G|C>T/);
		print OT "$region{$key}[$i][4]\t$region{$key}[$i][0]:$region{$key}[$i][1]-$region{$key}[$i][2]:$char\t$substitutions\t$contexts\t$motif\t$type\n";
	}
}
close OT;
exit;
