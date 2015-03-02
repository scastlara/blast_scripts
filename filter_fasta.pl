#!/usr/bin/perl
#################################################################################
#                               filter_fasta.pl									#
#################################################################################

#================================================================================
#        Copyright (C) 2014 - Sergio CASTILLO
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#================================================================================

use warnings;
use strict;
use Hash::Compare;
use Data::Dumper;

die "\nYou have to introduce two command line arguments:\n" .
	"\t- File with ids to remove from fasta (on the first column)\n" .
	"\t- Fasta file you want to filter\n\n"
	unless (@ARGV == 2);


#================================================================================
# VARIABLES
#================================================================================

my $filter_file = shift @ARGV;
my $fasta_file  = shift @ARGV;


#================================================================================
# MAIN LOOP
#================================================================================

my $unwanted_seqs = read_filter($filter_file);
my $fasta_seqs    = read_fasta($fasta_file);

my $comp = Hash::Compare->new(hash1 => $unwanted_seqs, 
							  hash2 => $fasta_seqs
							  );

my $filtered_fasta = $comp->get_unique("hash2");


#================================================================================
# FUNCTIONS
#================================================================================

#--------------------------------------------------------------------------------
sub read_filter {
	my $file 	 = shift;
	my %out_hash = ();

	open my $FH, "<", $file
		or die "Can't open $file : $!\n";

	while (<$FH>) {
		chomp;
		my ($unwanted_id) = split /\t/, $_;
		$out_hash{$unwanted_id} = undef;
	} # while

	return \%out_hash;
} # sub read_filter

#--------------------------------------------------------------------------------
sub read_fasta {
	my $fasta_file = shift;
	my %out_hash = ();

	open my $FASTA, "<", $fasta_file
		or die "Can't open $fasta_file : $!\n";	

	local $/ = ">";

	while (<$FASTA>) {
		chomp;
		my ($id, @seq) = split /\n/, $_;
		next unless $id;
		$out_hash{$id} = join "\n", @seq;

	} # while

	return \%out_hash;
}