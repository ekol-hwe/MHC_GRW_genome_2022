#!/usr/bin/perl -w
use strict;

my ($blast,$gff,$dist) = @ARGV;
#dist is a likely distace between 2 genes, depends if it is compact or not
#class I: dist = 10000
#class II: dist = 4000

my $gene_num = 1;
my (@sp,@hit);

open(GFF, " > $gff");
print GFF "#gff-version 3\n";
open(BLA, " < $blast");
while (<BLA>) {
    print "NEW LINE $_\n\n";
    chomp;
    @sp = split(/\t/,$_);
    if ($#hit == -1){
	#print "hit empty, push $_ in hit\n\n";
	push(@hit,$_);
	next;
    }
    else {
	my $last = $hit[-1];
	my @last = split(/\t/,$last);
	if (($sp[1] ne $last[1]) || ($sp[-1] != $last[-1])){
	    #if different scaffold or different frame +/-
	    # build new entry in gff file
	    $gene_num = BuildEntryGff($gene_num,\@hit);
	    @hit = ();
	    push(@hit,$_);
	    next;
	}
	elsif ($sp[0] eq $last[0]){
	    #same exon number
	    #need to discriminate between frameshift (=same exon) or duplication
	    if (($sp[3] + $last[3]) <= $sp[2] + 10){
		#could be frameshift based on aln length
		#print "if ((( $sp[-1] < 0 ) && ( $last[4] >= $sp[5] ) && ( $last[6] <= $sp[7] ) && ( $sp[7] - $last[6] < $sp[2] + 30 )) || (( $sp[-1] > 0 ) && ( $last[5] <= $sp[4] ) && ( $last[7] <= $sp[6] ) && ( $sp[7] - $last[6] < $sp[2] + 30 ))) {\n\n";
		if ((( $sp[-1] < 0 ) && ( $last[4] >= $sp[5] ) && ( $last[6] <= $sp[7] ) && ( $sp[7] - $last[6] < $sp[2] + 30 )) || (( $sp[-1] > 0 ) && ( $last[5] <= $sp[4] ) && ( $last[7] <= $sp[6] ) && ( $sp[7] - $last[6] < $sp[2] + 30))) {
		    #it's a frameshift
		    if ($sp[-1] > 0){
			$last[5] = $sp[5];
			$last[7] = $sp[7];
		    }
		    else {
			$last[4] = $sp[4];
			$last[6] = $sp[6];
		    }
		    if ($sp[3] + $last[3] <= $last[2]){
			$last[3] += $sp[3];
		    }
		    else {
			$last[3] = $last[2];
		    }
		    $last = join("\t",@last);
		    $hit[-1] = $last;
		    #print "hit-1 $hit[-1]\n";
		}
		else {
		    #it's a duplication
		    #build new entry in gff3 file
		    $gene_num = BuildEntryGff($gene_num,\@hit);
		    @hit = ();
		    push(@hit,$_);
		}
	    }
	    else {
		#it's a duplication
		#build new entry in gff3 file
		BuildEntryGff($gene_num,\@hit);
		@hit = ();
		push(@hit,$_);
	    }
	}
	else {
	    my $o = 0;
	    foreach my $past (@hit){
		my @old = split(/\t/,$past);
		if ($old[0] eq $sp[0]){
		    #exon already exists
		    #build new entry in gff3 file
		    $gene_num = BuildEntryGff($gene_num,\@hit);
		    @hit = ();
		    push(@hit,$_);
		    $o = 1;
		    last;
		}
	    }
	    if ($o == 0){
		$last[0] =~ /^(\d+)_/;
		my $exlast = $1;
		$sp[0] =~ /^(\d+)_/;
		my $exsp = $1;
		if ((($sp[-1] > 0) && ($exlast > $exsp)) || (($sp[-1] < 0) && ($exlast < $exsp))){
		    #wrong exon order
		    #build new entry in gff3 file
		    $gene_num = BuildEntryGff($gene_num,\@hit);
		    @hit = ();
		    push(@hit,$_);
		}
		
		elsif ((($sp[-1] < 0) && ($sp[7] - $last[6] > $dist)) || (($sp[-1] > 0) && ($sp[6] - $last[7] > $dist))){
		    #too far, probably another gene
		    #build new entry in gff3 file
		    $gene_num = BuildEntryGff($gene_num,\@hit);
		    @hit = ();
		    push(@hit,$_);
		}
		else {
		    push(@hit,$_);
		}
	    }
	}
    }
}
$gene_num = BuildEntryGff($gene_num,\@hit);
close(BLA); close(GFF);    

#function build entry
sub BuildEntryGff {
    #my @full = @{$_[0]};
    my ($num, $refhit) = @_;
    my @refhit = @{$refhit};
    my ($start,$end,$frame,$contig);
    foreach my $h (@refhit){
	my @filter = split(/\t/,$h);
	if (($filter[8] < 80) || (($filter[3] < ($filter[2]*0.66)) && ($filter[0] !~ /utr/))){
	    $h = "";
	}
    }
    #remove empty elements
    @refhit = grep { $_ ne '' } @refhit;
    if ($#refhit >= 0){
	my @fi = split(/\t/,$refhit[0]);
	my @la = split(/\t/,$refhit[-1]);
	$contig = $fi[1]; my $id = "mrna".$num;
	if ($fi[-1] > 0){
	    $start = $fi[6]; $end = $la[7]; $frame = "+";
	}
	else {
	    $start = $fi[7]; $end = $la[6]; $frame = "-";
	}
	print GFF "$contig\tblastn-short\tmrna\t$start\t$end\t.\t$frame\t.\tID=$id\n";
	#print "REFHIT @refhit\n";
	foreach my $h (@refhit){
	    @fi = split(/\t/,$h);
	    if ($fi[-1] > 0){
		print GFF "$contig\tblastn-short\texon\t$fi[6]\t$fi[7]\t.\t$frame\t.\tParent=$id;Name=$fi[0]\n";
	    }
	    else {
		print GFF "$contig\tblastn-short\texon\t$fi[7]\t$fi[6]\t.\t$frame\t.\tParent=$id;Name=$fi[0]\n";
	    }
	}
	$num ++;
    }
    return $num;
}




exit(0);
