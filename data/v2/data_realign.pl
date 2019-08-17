#!/usr/bin/perl
use lib "../";
use Common;
use strict;

my (%ingreds, %quantities);

opendir DIR, DATA_DIR;
foreach (readdir DIR) {
    /xml$/ or next;
    next if /indexes/;
    (my $entry = $_) =~ s/.xml//;
    system("cp", "$_", "$_.bak");

    my $data = load_entry($entry);
    $data->{notes} =~ s/\r//g;
    $data->{preparation} =~ s/\r//g;
    foreach my $ingred (@{$data->{ingredients}}) {
        unless ($ingred->{ingredient_name} =~ s/^\*+(.+):?/**\U$1/) {
            $ingred->{ingredient_name} = lc($ingred->{ingredient_name});
        }
        $ingred->{ingredient_name} =~ s/(beau monde|bisquick|old english|american|italian|frito|knorr|monterey|ro-tel|Tabasco|Cointreau|karo|spice_islands)/join('', map {ucfirst $_} split(m-(\s+)-, $1))/eg;
        $ingred->{ingredient_name} =~ s/(all purpose flour|gold medal flour)/all-purpose flour/g;
        $ingred->{ingredient_name} =~ s/cayanne/cayenne/g;
        $ingred->{ingredient_name} =~ s/(Worcestershire|Worcestershire Sauce|Worcetershire Sauce|Worchestershire sauce)/Worcester Sauce/g;
        $ingred->{ingredient_name} =~ s/\s+$//;

        $ingred->{preparation} =~ tr/A-Z/a-z/;
        $ingred->{preparation} =~ s/\s+$//;
        $ingred->{quantity} =~ tr/A-Z/a-z/;
        $ingred->{quantity} =~ s/(tsp|tbl)\./$1/;
        $ingred->{quantity} =~ s/tbl/tbsp/;
        $ingred->{quantity} =~ s/pgks/pkgs/;
        $ingred->{quantity} =~ s/package/pkg/;
        $ingred->{quantity} =~ s/quart/qt/;
        $ingred->{quantity} =~ s/\s+$//;
        $ingreds{$ingred->{ingredient_name}} = $entry;
        
        my $q = $ingred->{quantity} or next;
        $q =~ s=[\d/-]]+\s*==;
        $quantities{$q} = $entry;
    }
    save_data($data);
}

print "Ingredients: ", join("\n", map {sprintf("%-30.30s %s", $_, $ingreds{$_})} sort keys %ingreds), "\n\n";
print "Quantities: ", join("\n", map {sprintf("%-10.10s %s", $_, $quantities{$_})} sort keys %quantities), "\n";
