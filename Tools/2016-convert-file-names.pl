#!/usr/bin/perl

# Copy files from underscore method names to hyphen names.  Hyhphens
# are hyphier but damn this breaks everything.  Good thing I' pretty
# anonyous in Google :) [BP -- 9 Jan 2016]

use strict;

use File::Find;

find(\&process_files, "$ENV{HOME}/billpollock.com/eathappy/data");

system("2016-rebuild-indexes.pl");

sub process_files {
    return unless /xml$/;
    my $path = $File::Find::name;
    my $dir  = $File::Find::dir;
    my $src  = join('/', $dir, $_);

    (my $idxsrc = join('/', $dir, $_)) =~ s/.xml/.idx/;

    return unless -e $idxsrc;

    -e $idxsrc or next;

    (my $newname = $_) =~ s/_/-/g;

    my $dest = join('/', $dir, $newname);
    (my $idxdest = $dest) =~ s/.xml/.idx/;

    if ($src ne $idxsrc) {
        print "$src\n$dest\n";
        rename($src, $dest) or die "FATAL: can't move file -- $!\n";
    }
    if ($idxsrc ne $idxdest) {
        print "\t$idxsrc\n\t$idxdest\n\n";
        rename($idxsrc, $idxdest) or die "FATAL: can't move index - $!\n";
    }
}
