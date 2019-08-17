package EatHappy::Recipe::IndexEntry;

# In a perfet world this is handled by ORM meethods nad is really an Entry.pm record
# but since the index file is kind of like ORM in that it only gives us some stuff
# and in a weird form, tough tees. [BP -- 18 Jan 2015]

# WAS package EatHappy::EntryIndex;

# Something of a misnomer -- these are entry -items-

use strict;
use Storable qw(retrieve nstore);
use Date::Manip;
use Carp;
use parent 'Class::Accessor';
use parent 'EatHappy::Base::FileSystemMethods';

EatHappy::Recipe::IndexEntry->mk_accessors(qw(cdate collectionName dataset entry_app entry_name ingredients name notes prep_time preparation primary_category recipeLabel recipeName safe_name secondary_categories sourcePage source_author source_date source_name source_page twig user yield_count yield_measure));


my %dataset_tags;

sub new {
    my($class, %opts) = @_;
    my $self = bless \%opts, $class;

    $self->{safe_name} ||= $self->{entry_name};

    return $self;
}

sub is_new {
    my($self) = @_;
    return $self->_has_property('is_new');
}

sub is_untried {
    my($self) = @_;
    return $self->_has_property('is_untried');
}

sub is_updated {
    my($self) = @_;

    my $start_date = $self->_ds_catfind('is_updated');

    my $last_mod = $self->{mdate} || $self->{cdate};

    if (Date_Cmp($last_mod, $start_date) >= 0) {
        return 1;
    } else {
        return 0;
    }
}

sub is_deleted {
    my($self) = @_;
    return $self->_has_property('is_deleted');
}

sub has_secondary {
    my($self, %opts) = @_;
    return grep($opts{name} eq $_, $self->secondary_categories) ? 1 : 0;
}

sub secondary_categories {
    my($self) = @_;

    return unless $self->{secondary_categories};
    return @{$self->{secondary_categories}};

}

sub save($) {
    my($self) = @_;

    my $name = $self->recipeName or die "FATAL: No name generated";

    my $index_entry = {
        name => $self->{name}, # FGUGUGUGG, LET IT GOOOO, LET IT GOOOO
        safe_name => $name,
        primary_category => $self->{primary_category},
        secondary_categories => $self->{secondary_categories},
        untried => $self->{untried} ? 1 : 0,
        dataset => $self->{dataset},
        cdate => $self->{cdate},
        mdate => $self->{mdate},
    };

    my $idxpath = $self->_index_path
        or die "FATAL: no name generated from $self->{name}";

    nstore $index_entry, $idxpath
        or die "FATAL: couldn't open $idxpath!\n";

    chmod 0666, $idxpath;

    # Purge old record
    if ($self->{originalRecipeName}) {
        my $oldPath = $self->_index_path($self->{collectionName},
                                         $self->{originalRecipeName});
        unlink($oldPath) if $oldPath ne $idxpath;
    }

    $self->update_index($index_entry); # Duh, here
}

# CRAPULENT INTERFACE 
sub load {
    my ($self, $dataset, $id) = @_;

    my $idxpath = $self->_index_path($dataset, $id)
        or die "FATAL: no name generated from $id}";

    my $return = retrieve($idxpath)
        or die "No retrieve for $idxpath\n";

    $return->{source} = $idxpath;
    return $return;
}

sub last_update {
    my($self) = @_;

    return $self->{mdate} || $self->{cdate};
}

# Rather than parse and re
sub update_index {
    my($self, $new_entry) = @_;
    die unless $new_entry;

    my $colIdxPath = $self->_collection_index_path or die "FATAL: generated no colIdxPath";;

    my $colIdx = retrieve($colIdxPath) or die "No retrieve for $colIdxPath\n";

    $new_entry;
    if ($self->{originalRecipeName}) {
        # Get the oroginal rec out
        $colIdx = [grep($self->{originalRecipeName} ne
			$_->{safe_name}, @{$colIdx})];
    }

    push(@{$colIdx}, $new_entry);
    nstore($colIdx, $colIdxPath);
}


sub _has_property {
    my($self, $is_type) = @_;
    return $self->{$is_type} if $self->{$is_type};

    my $category = $self->_ds_catfind($is_type) or
	die "FATAL: no category returned for $is_type";

    return grep($category eq $_, $self->secondary_categories);
}

sub _ds_catfind {
    my($self, $type) = @_;
    return $dataset_tags{$type}->{$self->{dataset}} if
        $dataset_tags{$type}->{$self->{dataset}};

    my $eh = EatHappy->new(dataset => $self->{dataset});
    if ($type eq 'is_new') {
        return $dataset_tags{$type}->{$self->{dataset}} = 
            $eh->new_entry_category;
    } elsif ($type eq 'is_deleted') {
        return $dataset_tags{$type}->{$self->{dataset}} = 
            $eh->deleted_entry_category;
    } elsif ($type eq 'is_updated') {
        return $dataset_tags{$type}->{$self->{dataset}} = 
            $eh->dataset_start_date;
    } else {
        die "FATAL: unknown type $type\n";
    }
}

sub _index_path($$) {
    my($self, $collection, $id) = @_;
    $collection ||= $self->{collectionName};
    $id ||= $self->{recipeName};

use Data::Dumper;
#die(Data::Dumper->Dump([$self])) unless $collection;

    confess "No collection" unless $collection;
    confess "No id" unless $id;

    require EatHappy::Recipe::XML;
    my $base = EatHappy::Recipe::XML->entry_path({collectionName => $collection,
						  recipeName => $id,
						 });

    $base =~ s/xml/idx/ or die "FATAL -- couldn't convert xml to idx in $base";
    return $base;
}

sub _collection_index_path {
    my($self) = @_;
    my $data_dir = $self->dataset_path;
    my $outpath = join('/', $data_dir, "indexes.idx"); # 
    return $outpath
}

return 'a true value';
