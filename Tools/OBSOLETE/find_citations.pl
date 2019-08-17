#!/usr/bin/perl
use Common;
#system("zip", "-m", ",idxback", join('/', DATA_DIR, "*idx")); 
opendir DIR, DATA_DIR;
foreach (readdir DIR) {
    /xml$/ or next;
    next if /indexes/;
    (my $entry = $_) =~ s/.xml//;


    my $data = load_entry($entry);
    next unless $data->{notes} =~ /(From|Originally)/;
    print "$entry\n";
    print "$data->{notes}\n";
#    use Data::Dumper;
#    die Data::Dumper->Dump([$data]);

}
rebuild_index();
