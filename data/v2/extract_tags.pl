#!/usr/bin/perl

opendir DIR, "./";
use XML::Parser;
$x = XML::Parser->new(Handlers => {Start => sub { $tagcount{$_[1]}++}});
foreach my $file (readdir DIR) {
    next unless $file =~ /xml$/;
    next if $file eq 'indexes.xml';
    $x->parsefile($file);
}

foreach (sort keys %tagcount) {
    print "$_\n";
}
