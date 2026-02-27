#!/usr/bin/perl -w
use strict;

my ($samplelist,$indir,$ot,$suffix)=@ARGV;

$suffix ||="hg38_multianno.txt.gz";

my %Annotation =(
	'frameshift insertion' => 'Frame_Shift_Ins',
	'frameshift deletion' => 'Frame_Shift_Del',
	'nonframeshift insertion' => 'In_Frame_Ins',
	'nonframeshift deletion' => 'In_Frame_Del',
	'nonframeshift substitution' => 'Substitution',
	'nonsynonymous SNV' => 'Missense_Mutation',
	'synonymous SNV' => 'Silent',
	'stopgain' => 'Nonsense_Mutation',
	'stoploss' => 'Nonstop_Mutation',
	'splicing' => 'Splice_Site');


if($ot=~/\.gz$/){open OT,"|gzip >$ot" or die $!;}else{open OT,">$ot" or die $!;}
#print OT "Hugo_Symbol\tEntrez_Gene_Id\tCenter\tNCBI_Build\tChromosome\tStart_Position\tEnd_Position\tStrand\tVariant_Classification\tVariant_Type\tReference_Allele\tTumor_Seq_Allele1\tTumor_Seq_Allele2\tTumor_Sample_Barcode\n";
print OT "Hugo_Symbol\tEntrez_Gene_Id\tCenter\tNCBI_Build\tChromosome\tStart_Position\tEnd_Position\tStrand\tVariant_Classification\tVariant_Type\tReference_Allele\tTumor_Seq_Allele2\tTumor_Sample_Barcode\tTumorVAF\tTumor_Ref_reads\tTumor_Var_reads\tNormal_Ref_reads\tNormal_Var_reads\n";
open INL,"$samplelist" or die $!;
while (<INL>){
	chomp;
	my $sample=$_;
	$sample=~s/\s+//g;
	my %column;
	my $f="$indir/$sample/$sample.$suffix";
	if($f=~/\.gz$/){open IN,"gunzip -cd <$f|" or die $!;}else{open IN,"<$f" or die $!;}
	while (<IN>){
		chomp;
		my @t=split /\t/;
		if ($.==1){
			foreach my $i(0..@t-1){
				$column{$t[$i]}=$i;
#				print "$t[$i]\t$i\n";
			}
#			print OT "$_\n";
			next;
		}
	#	next if $t[$column{'Func_refGene'}]=~/intergenic|upstream|downstream|ncRNA_|intronic|UTR3|UTR5/;
		next unless $t[$column{'Otherinfo10'}]=~/PASS/;
#		print OT "$_\n";			
		my $Chromosome =$t[$column{'Chr'}];
		my $Start_Position =$t[$column{'Start'}];
		my $End_Position =$t[$column{'End'}];

		my $Hugo_Symbol =$t[$column{'Gene_refGene'}];
		my $Entrez_Gene_Id =$Hugo_Symbol;

		my $Center="BGI";
		my $NCBI_Build="GRCh38";

		my $Reference_Allele =$t[$column{'Ref'}];
		my $Tumor_Seq_Allele1 =$t[$column{'Ref'}];
		my $Tumor_Seq_Allele2 =$t[$column{'Alt'}];
		my $Strand="+";

		my $Func_refGene =$t[$column{'Func_refGene'}];
		my $ExonicFunc_refGene = $t[$column{'ExonicFunc_refGene'}];

		my $Variant_Classification;
		if ($ExonicFunc_refGene=~/\./){
			if (exists $Annotation{$Func_refGene}){
				$Variant_Classification=$Annotation{$Func_refGene};
			}
			else {
				$Variant_Classification=$Func_refGene;
			}
		}
		else {
			if (exists $Annotation{$ExonicFunc_refGene}){
				$Variant_Classification=$Annotation{$ExonicFunc_refGene};
			}
			else {
				print "$ExonicFunc_refGene\n";
				$Variant_Classification=$ExonicFunc_refGene;
			}
		}

		my $Variant_Type;
		my $length_Reference_Allele=length($Reference_Allele);
		my $length_Tumor_Seq_Allele2=length($Tumor_Seq_Allele2);
		if ($Tumor_Seq_Allele2 eq "-"){$Variant_Type="DEL";}
		elsif ($Reference_Allele eq "-"){$Variant_Type="INS";}
		elsif ($length_Reference_Allele eq $length_Tumor_Seq_Allele2){
			if ($length_Reference_Allele eq "1"){$Variant_Type="SNP";}
			elsif ($length_Reference_Allele eq "2"){$Variant_Type="DNP";}
			elsif ($length_Reference_Allele eq "3"){$Variant_Type="TNP";}
			elsif ($length_Reference_Allele > 3){$Variant_Type="ONP";}
			else {print "$Reference_Allele\t$Tumor_Seq_Allele2\n";}
		}
		else {print "$Reference_Allele\t$Tumor_Seq_Allele2\n";}

		my $TumorVAF=(split /:/,$t[$column{'Otherinfo14'}])[2];
#		print "$t[$column{'Otherinfo14'}]\n";
		my ($Tumor_Ref_reads, $Tumor_Var_reads) = split /,/, (split /:/,$t[$column{'Otherinfo14'}])[1];
		my ($Normal_Ref_reads, $Normal_Var_reads) = split /,/, (split /:/,$t[$column{'Otherinfo13'}])[1];
		my $Tumor_Sample_Barcode =$sample;
#		my $line="$Hugo_Symbol\t$Entrez_Gene_Id\t$Center\t$NCBI_Build\t$Chromosome\t$Start_Position\t$End_Position\t$Strand\t$Variant_Classification\t$Variant_Type\t$Reference_Allele\t$Tumor_Seq_Allele1\t$Tumor_Seq_Allele2\t$Tumor_Sample_Barcode";
		my $line="$Hugo_Symbol\t$Entrez_Gene_Id\t$Center\t$NCBI_Build\t$Chromosome\t$Start_Position\t$End_Position\t$Strand\t$Variant_Classification\t$Variant_Type\t$Reference_Allele\t$Tumor_Seq_Allele2\t$Tumor_Sample_Barcode\t$TumorVAF\t$Tumor_Ref_reads\t$Tumor_Var_reads\t$Normal_Ref_reads\t$Normal_Var_reads";
		print OT "$line\n";
	}
	close IN;
}
close INL;
close OT;
exit;
