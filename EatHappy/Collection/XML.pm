package EatHappy::Collection::XML;

# EatHappy::Collection::XML - Provides abstracted functionality so as to leave parent class content-agnostic
# ---------------------------------------------------------------------------
use strict;

use constant NO_DELETED => 1;
use Carp;

use parent "EatHappy::Base::FileSystemMethods";

sub new {
    my ($class, %opts) = @_;

    my $self = bless %opts, $class;

    return $self;
}

sub collection_index {
    my ($self, %opts) = @_;
    my $infile = join('/', $self->dataset_path(%opts), 'indexes.idx');

    my @return;

    require EatHappy::Recipe::IndexEntry;

    if (-e $infile) {
        my $index;
        require Storable;
        import Storable 'retrieve';

        eval {$index = retrieve($infile) or confess "FATAL: no index load";};

        if ($@) {
            die "Problems with retrieval of $infile -- $@";
        }

        if ($opts{category}) {
            @{$index} =
              grep($_->{primary_category} eq $opts{category}, @{$index});
        }

        if ($opts{subcategory}) {
            my @newindex;

            foreach my $item (@{$index}) {
                if ($opts{subcategory} eq 'Untried') {
                    push(@newindex, $item) if $item->{untried};
                } else {
                    $item->{secondary_categories} or next;
                    grep($opts{subcategory} eq $_,
                         @{$item->{secondary_categories}})
                      and push(@newindex, $item);
                }
            }
            @{$index} = @newindex;
        }

        if ($opts{limits}) {
            my (@newindex);
            if (grep($_ eq NO_DELETED, @{$opts{limits}})) {
                foreach (@return) {
                    next if $_->is_deleted;
                    push(@newindex, $_);
                }
                confess if $#newindex == $#return;
            }
            @return = @newindex;
        }

        @return = map {EatHappy::Recipe::IndexEntry->new(%{$_})} @{$index};

        if ($opts{sort} eq 'primary category') {
            @return = sort {
                     $a->{primary_category} cmp $b->{primary_category}
                  || $a->{name} cmp $b->{name}
            } @return;
        } else {
            @return = sort {$a->{name} cmp $b->{name}} @return;

        }
        return @return;
    } else {
        confess "FATAL: couldn't open index file $infile -- $!";
    }
}

# Unlike the upsell into Eathappy::Collection::Entries, this call
# is only necessary for filebound access and likely only good for
# external apps. [BP -- 15 Jan 2016]
sub rebuild_index {
    my ($package, %opts) = @_;

    # Pull each of the index files
    # and thence push them into the breach

    require EatHappy::Recipe::IndexEntry;

    my @master_index = ();
    my $src_dir      = $package->dataset_path(%opts);

    my $dest_path = $package->_index_path(%opts);

    opendir my $dir, $src_dir or die "FATAL: could not open $dest_path\n";
    print "Processing $src_dir\n";
    foreach my $file (readdir($dir)) {

        $file =~ /idx$/ or next;
        $file =~ /indexes\.idx/ and next;    # whoops!  Recursive!
        (my $id = $file) =~ s/(.+)\.idx$/$1/ or confess "Can't convert $_";
        $id or confess "No ID ($id) $_";

        print "Loading $file\n" if $opts{verbose};

        my $ei = EatHappy::Recipe::IndexEntry->new(%opts);

        my $d = $ei->load($ei->collectionName, $id);

        # Well, modified the filename in the script...
        $d->{safe_name} =~ s/_/-/g;

        push(@master_index, $d);
    }

    require Storable;
    import Storable qw(nstore);

    nstore(\@master_index, $dest_path);
    print "Wrote $dest_path\n";

    chmod 0664, $dest_path;

}

sub _index_path {
    my ($package, %opts) = @_;

    return join('/', $package->dataset_path(%opts), 'indexes.idx');
}

return 1;
