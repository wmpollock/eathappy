package EatHappy::Recipe::XML;

use strict;

use parent "EatHappy::Base";
use parent "EatHappy::Base::FileSystemMethods";
use parent "EatHappy::Recipe";

use Carp; # everyone loves to carp

my %newToLegacy = (
		   collectionName => 'dataset',
		   recipeLabel => 'name',
		   yieldQuant => 'yield_count',
		   yieldUnit => 'yield_measure',
		   prepTime => 'prep_time',
		   sourceDate => 'source_date',
		   sourceAuthor => 'source_author',
		   sourcePage => 'source_page',
		   sourceTitle => 'source_name',
		   recipeName => 'entry_name',
);



sub save {
    my ($self) = @_;

    # Lets not junk up our XML just to make a point, we can cast back and forth...
    $self->_map_new_to_legacy;

    (my $name = $self->recipeName)
        or confess "FATAL: No name generated (from: \$self->safe_name)";

    use XML::Twig;
    my $twig = XML::Twig->new(pretty_print => 'indented');
    my $root = XML::Twig::Elt->new('recipe');
    $twig->set_root($root);
    $self->{twig}->{root} = $root;

    # I'm going to go through more work than I need to in order to 
    # keep the files humanly readable (for now).
    foreach (qw(name safe_name primary_category untried )) {
	$self->_xaddSelf($_);
    }

    my $secondary_categories = $root->insert_new_elt('last_child', 'secondary_categories');
    foreach my $category (@{$self->{secondary_categories} || []}) {
        $secondary_categories->insert_new_elt('last_child', 'secondary_category', $category)
    }

    foreach (qw(yield_count yield_measure prep_time notes)) {
	$self->_xaddSelf($_);
    }
    my $ingredients = $root->insert_new_elt('last_child', 'ingredients');

    foreach my $i_set (@{$self->{ingredients} || []}) {
        my $xml_set = XML::Twig::Elt->new('ingredient');
        foreach (qw(quantity ingredient_name preparation)) {
            $xml_set->insert_new_elt('last_child', $_, $i_set->{$_});
        }
        $xml_set->move('last_child', $ingredients);
    }

    foreach (qw(preparation source_author source_name source_page source_date entry_app
                cdate mdate user)) {
	$self->_xaddSelf($_);
    }

    my ($outpath) = $self->entry_path($self) or
      die "no \$outpath!";

    open OUT, ">", $outpath or 
        confess "FATAL: couldn't open $outpath -- $!!\n";
    print OUT $twig->sprint;
    close OUT;
    chmod 0644, $outpath;

    # Remove old name if the old name is inconsistent
    if ($self->{originalRecipeName}) {
	my $oldPath = $self->entry_path({%{$self},
					recipeName => $self->{originalRecipeName}});
	unlink($oldPath) if $oldPath ne $outpath; # 'cause, duh.
    }
    # Keep them files straight -- for now...

    require EatHappy::Recipe::IndexEntry;
    my $idx = EatHappy::Recipe::IndexEntry->new(%{$self});
    $idx->save;

    return 1;
}

# THIS FUNCTION WITH LEGACY NAMING
sub load {
    my($self, $args) = @_;

    ref($args) or confess("Bogus args: not a reference");
    $self->_map_new_to_legacy($args);    # THIS FUNCTION WITH LEGACY NAMING
    # {entry} -- WTF, legcy.
#    my($dataset, $entry_name) = ($args->{dataset}, ($args->{entry_name} || $args->{entry}));
    # recipeName s/b new args..?
    my($dataset, $entry_name) = ($args->{dataset}, $args->{safe_name} || $args->{recipeName} );

    confess( "Missing entry name.\n", (Data::Dumper->Dump([$self, $args, $dataset]))) unless $entry_name;

    my $infile = $self->entry_path($args);

    confess "No entry matching '$infile'" unless -e $infile;

    my $x = XML::Node->new;

    our(%entry, $index);

    %entry = (entry_name => $entry_name);

    foreach (
	qw(name primary_category yield_count yield_measure
           preparation notes prep_time cdate mdate source_name source_page
	   source_author
           source_date)) {
        $x->register(">recipe>$_", char => \$entry{$_});
    }

    $x->register('secondary_category', char => 
                 sub {
                     $_[1]=~ /^\s*$/ and return; 
                     push(@{$entry{secondary_categories}}, 
                          $_[1]);
                 }
        );

    my %ingred_data;
    foreach ('ingredient_name', 'quantity', 
	     '>recipe>ingredients>ingredient>preparation') {
        (my $last = $_ ) =~ s/.+>//;
        $x->register($_, char => \$ingred_data{$last});
    }
    $x->register('ingredient', end => sub {
		     # Pullup headings -- TODO: this model is stil kind of crap
		     if (my ($h) =  ($ingred_data{ingredient_name} =~ /^\*+(.+)/)) {
			 $ingred_data{heading} = $h;
		     }
		     # NOTE:  INCONSISTENT WITH (CURRENT) DATA MODEL
		     $ingred_data{ingredientPrepDesc} = $ingred_data{preparation};
		     push(@{$entry{ingredients}}, {%ingred_data}); 
		     map {$ingred_data{$_} = undef} keys %ingred_data
		 });

    $x->register('untried', start => sub {$entry{untried} = 1});

    eval {
        $x->parsefile($infile);
    };

    if ($@) {
        confess "FATAL: exception in parsing $infile -- $@";
    }

    # a little cleanup
    delete $entry{prep_time} if $entry{prep_time} eq '00:00';

    $entry{collection} = $dataset;
    $entry{xml_path} = $infile;
    $entry{dataset} = $dataset;

    _map_legacy_to_new(\%entry); # API-ize content

    return EatHappy::Recipe->new(%entry);
}

sub entry_path {
    my($package, $args) = @_;

    my $er = EatHappy::Recipe->new(%{$args});
    my $recipeName = $er->recipeName or die "NO NAME?!?!";

    #TODO:  fugging dataset_path args are nonconsisten, we're all up in hashes here... is lame [BP -- 15 Feb 2015]

    # Also some inconsistency about old records being underscored and 
    # new records being hyphenated.  For The Good Of The Internet would
    # require consistency in the URLs with like some bit of fancypants

    my $infile = join('/', $package->dataset_path(%{$args}), $recipeName . ".xml");
    return $infile;

}

sub _map_new_to_legacy {
    my($self, $args) = @_;

    confess("Bogus object") unless ref($self);
    confess("Bogus args -- $args is not a reference") if ($args and not ref($args));
    $args ||= {};
    foreach (keys %newToLegacy) {
	$self->{$newToLegacy{$_}} ||= $self->{$_};
	$args->{$newToLegacy{$_}} ||= $args->{$_};
    }
}

sub _map_legacy_to_new {
    my($self) = @_;
    my %legacyToNew = reverse %newToLegacy;

    foreach (keys %legacyToNew) {
	$self->{$legacyToNew{$_}} ||= $self->{$_};
    }
}

sub _xaddSelf {
    my($self, $name) = @_;
    $self->{twig}->{root}->insert_new_elt('last_child', $name, {}, $self->{$name} || '');
}

return 1;
