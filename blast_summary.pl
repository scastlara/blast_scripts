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
my %query_sons  = count_sons(\%query_x_targ);
my %target_sons = count_sons(\%targ_x_query);

write_out(	\%query_x_targ,
		  	\%targ_x_query,	
		  	\%query_sons,
		  	\%target_sons
		  );

#print Data::Dumper->Dump([\%query_sons, \%target_sons],[qw/QUERY TARGET/]);

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
sub count_sons {
	my $hash  = shift;
	my %count = ();
	

	foreach my $key (keys %{ $hash }) {
		
		my $number_sons = values(%{ $hash->{$key} });

		if ($number_sons == 1) {
			$count{1}++;
		} else {
			$count{n}++;
		}

	}

	return(%count);
} # sub count_sons

#--------------------------------------------------------------------------------
sub write_out {
	my $query_x_targ = shift;
	my $targ_x_query = shift;	
	my $query_sons   = shift;
	my $target_sons  = shift;

	
	print_out("Q", $query_x_targ);
	print_out("T", $targ_x_query);
	print "\n\n";
	print_stats("Stats for queries", "1-n", $query_sons);
	print_stats("Stats for targets", "n-1", $target_sons);
	
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
sub print_stats {
	my $str      = shift;
	my $scnd_str = shift;
	my $hash     = shift;

	print "$str:\n";
	print "1-1" . "\t" . "$hash->{1}\n";
	print "$scnd_str" . "\t" . "$hash->{n}\n";

} # sub print_stats