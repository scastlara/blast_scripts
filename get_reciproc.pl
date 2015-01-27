#!/usr/bin/perl
#
#################################################################################
#                               get_reciproc.pl									#
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
use Getopt::Std;
use Data::Dumper;

#================================================================================
# VARIABLES
#================================================================================
my $cthulhu_file = shift @ARGV;
my $cov_file     = shift @ARGV;
my %plan_ids     = ();

#================================================================================
# MAIN LOOP
#================================================================================
read_ids($cthulhu_file, \%plan_ids);
parse_cov_file($cov_file, \%plan_ids);

write_output(\%plan_ids);

#================================================================================
# FUNCTIONS
#================================================================================

#--------------------------------------------------------------------------------
sub read_ids {
	my $id_file  = shift;
	my $plan_ids = shift;

	open my $ID, '<', $id_file
		or die "Can't open $id_file : $!\n";

	<$ID>; # skip header
	while (<$ID>) {
		chomp;
		my ($id, $length) = split /\s/, $_;
		$plan_ids->{$id}->{L} = $length; 
	} # while
	
	return;

} # sub read_ids


#--------------------------------------------------------------------------------
sub parse_cov_file {
	my $cov_file = shift;
	my $plan_ids = shift;
	my %double   = ();

	open my $COV, '<', $cov_file
		or die "Can't open $cov_file : $!\n";

	while (<$COV>) {
			chomp;
			my @columns = split /\t/, $_;

			if ($columns[0] eq 'Q') {
				my ($tr_name) = split /\s/, $columns[13]; # target
				$double{$tr_name}->{$columns[1]} = undef; # {target}->{query}
			} elsif ($columns[0] eq 'T') {
				my ($tr_name) = split /\s/, $columns[13]; # query
				
				if (exists $double{ $columns[1] }) {
					
					if (exists $double{ $columns[1] }->{$tr_name}) {
						$plan_ids{$tr_name}->{$columns[1]} = "hello";
					}
				
				} 


			}
		
		}

	return;			

} # sub parse_cov_file


#--------------------------------------------------------------------------------
sub write_output {
	my $plan_hash = shift;

	print "PLAN_TRANSCRIPT" . "\t". "RECIPROC" . "\t" . "TRANSCRIPT_LENGTH" . "\n";

	foreach my $seq (keys %{ $plan_hash }) {
		
		if (scalar(keys $plan_hash->{$seq}) == 1) {
			print "$seq" . "\t" . "NA" ."\t" . "$plan_hash->{$seq}->{L}" . "\n"; 
		} else {
			
			foreach my $reciproc (keys  %{ $plan_hash->{$seq} }) {
				next if $reciproc eq 'L';
				print "$seq" . "\t" . "$reciproc" ."\t" . "$plan_hash->{$seq}->{L}" . "\n";
			} # foreach rec
		
		} # if reciproc

	} # foreach sequence

	return;

} # sub write_output