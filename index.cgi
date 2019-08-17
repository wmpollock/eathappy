#!/usr/bin/perl
#    _____      _   _   _
#   | ____|__ _| |_| | | | __ _ _ __  _ __  _   _
#   |  _| / _` | __| |_| |/ _` | '_ \| '_ \| | | |
#   | |__| (_| | |_|  _  | (_| | |_) | |_) | |_| |
#   |_____\__,_|\__|_| |_|\__,_| .__/| .__/ \__, |
#                              |_|   |_|    |___/

# Pollock, 2015-

use strict;
use CGI qw(:all);
use CGI::Carp qw(fatalsToBrowser);
use lib "./";
use EatHappy::Online;


my $eo = EatHappy::Online->new;
my $args = $eo->get_args;
#use Data::Dumper;die(Data::Dumper->Dump([$args]));
use Data::Dumper;
#die(Data::Dumper->Dump([$args]));


if ($eo->mode('show') and $args->{entry}) {
    $eo->render_recipe;
# TODO: This should 
} elsif ($eo->mode('show')) {
    $eo->render_index; # Full content of cat/subcat
} elsif ($eo->mode('list')) {
    $eo->render_index; # Core of list
} elsif ($eo->mode('edit')) {
    $eo->render_editor;
} elsif ($eo->mode('save')) {
    $eo->render_save;
} else {
    die "FATAL: unhandled mode -- '", $eo->mode, "'";
}

