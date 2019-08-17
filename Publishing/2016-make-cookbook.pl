#!/usr/bin/perl

use strict;
use lib "$ENV{HOME}/billpollock.com/eathappy";
use lib "$ENV{HOME}/billpollock.com/Common/Perllib";
use lib "$ENV{HOME}/Perllib/lib";

#my $webfile = '/web/billpollock.com/cookbook.rtf';

use EatHappy::Collections;
use EatHappy::Publish::RTF;

#TODO: Need to add handling for other books
my ($collection) = EatHappy::Collections->default;

use Data::Dumper;

#print(Data::Dumper->Dump([$collection]));

my $date = [localtime time];
my $outfile = sprintf("cookbook_%s_%4.4d%2.2d%2.2d.rtf", $collection->collectionName, $date->[5] + 1900, $date->[4] + 1,
                      $date->[3]);

#unlink($webfile);

my $eh = EatHappy::Publish::RTF->new;

$eh->format_collection($collection, outfile => $outfile)
  or die "WHAT THE FIGGITY?";

#$eh->format_cookbook(
#    outfile => $outfile,
#    sortby => 'title',
#    );

#system('cp', $outfile, $webfile);
die if $?;

print "Created $outfile\n";

#print "Published $webfile\n";

print "\nRemaining tasks for You, The Editor:\n";
print "\nInsert table of contents.\n";
