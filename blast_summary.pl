#/usr/bin/perl
#
#################################################################################
#                               blast_summary.pl									#
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
my $blast_file = shift;
my %query_x_targ = ();
my %targ_x_query = ();

#================================================================================
# MAIN LOOP
#================================================================================
get_results($blast_file, \%query_x_targ, \%targ_x_query);

my %query_results  = count_groups(\%query_x_targ, \%targ_x_query);
my %target_results = count_groups(\%targ_x_query, \%query_x_targ);

write_out(	\%query_x_targ,
		  	\%targ_x_query,	
		  	\%query_results,
		  	\%target_results
		  );


#================================================================================
# FUNCTIONS
#================================================================================

#--------------------------------------------------------------------------------
sub get_results {
	my $file = shift;
	my $query_x_targ = shift;
	my $targ_x_query = shift;

	open my $BLAST, '<', $file
		or die "Can't open $file : $!\n";

	while (<$BLAST>) {
		chomp;
		my ($query, $junk, $target) = split /\t/, $_;
		
		# Queries
		$query_x_targ->{$query}->{$target} = undef;
	
		# Targets
		$targ_x_query->{$target}->{$query} = undef;
	}

	return;

} # sub get_results



#--------------------------------------------------------------------------------
sub count_groups {
	my $primary_hash   = shift;
	my $secondary_hash = shift;
	my %results = ("1-1" => undef, 
				   "n-1" => undef,
				   "1-n" => undef,
				   "n-n" => undef
				   );

	foreach my $key (keys %{ $primary_hash }) {
		my @sons = keys %{ $primary_hash->{$key} };
		
		if (@sons == 1) {
			my @sons_keys = keys %{ $secondary_hash->{$sons[0]} };
			
			if (@sons_keys == 1) {
				$results{"1-1"}++;
			} else {
				$results{"n-1"}++;
			}
		
		} else {

			my $flag = 0; 

			foreach my $son (@sons) {

				if (keys %{ $secondary_hash->{$son} } > 1) {
					$flag = 1;
				}
			
			}

			if ($flag == 0) { 		# no son has more than 1 key
				$results{"1-n"}++;
			} else {				# at least 1 son has more than 1 key
				$results{"n-n"}++;
			}

		}
	}

	return (%results);
}


#--------------------------------------------------------------------------------
sub write_out {
	my $query_x_targ = shift;
	my $targ_x_query = shift;	
	my $query_results   = shift;
	my $target_results  = shift;

	
	print_out("Q", $query_x_targ);
	print_out("T", $targ_x_query);
	print "\n\n";
	print_results('QUERIES', \%query_results);
	print_results('TARGETS', \%target_results);
	
} # sub write_out

#--------------------------------------------------------------------------------
sub print_out {
	my $l    = shift;
	my $hash = shift;

	foreach my $key (keys %{ $hash }) {
		print "$l\t". "$key\t" . join(",", keys( %{ $hash->{$key} })) . "\n";
	}

} # sub print_out


#--------------------------------------------------------------------------------
sub print_results {
	my $str      = shift;
	my $hash     = shift;

	print "$str:\n";
	
	foreach my $key (keys %{ $hash }) {
		print "$key\t$hash->{$key}\n";
	}

} # sub print_stats


#print Data::Dumper->Dump([\%query_results, \%target_results ],[qw/QUERY TARGET/]);
