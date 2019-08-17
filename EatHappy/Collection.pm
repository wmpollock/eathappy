package EatHappy::Collection;

#   ___         __   __             ___  __  ___    __
#  |__  |__| ../  ` /  \ |    |    |__  /  `  |  | /  \ |\ |
#  |___ |  | ..\__, \__/ |___ |___ |___ \__,  |  | \__/ | \|
#

# AKA Datasets, a class set
# ---------------------------------------------------------------------------

use strict;
use Carp;

use parent "EatHappy::Base::FileSystemMethods";
#use parent "EatHappy::Base::Autoload";
use parent "Class::Accessor";

#WTF COLLECITONLABEL V COLLCATIONNAME?!?!

EatHappy::Collection->mk_accessors( qw(collectionName)); # set in new()

sub new {
   my($class, %opts) = @_;

   my $self = bless \%opts, $class;
   if ($opts{dataset}) {
       require EatHappy::Legacy::Config;
       %opts = (
		EatHappy::Legacy::Config->collection_config($opts{dataset}),
		%opts
	       );
    }
   return $self;
}

# TODO -- this thing sure as shit should be passing arguments from $self
# sufficient that we don't need %opts?@@?@?
sub entries {
    my($self, %opts) = @_;
    my @return;

    # Abstract the functions here in the XML so they could be leveraged out at some point
    # .. I guess
    require EatHappy::Collection::XML;
    return EatHappy::Collection::XML->collection_index(%{$self}, %opts);
}

sub primary_categories {
    my($self) = @_;

    return map {$self->_remap_cat($_, 'p')} $self->_file_to_list('categories');
}

sub secondary_categories {
    my($self) = @_;
    return map {$self->_remap_cat($_, 's')} $self->_file_to_list('secondary_categories');
}
# TODO:  Obsolete this shit into instantiate-collection-once :/ [BP -- 23 Sep 2017]
# sub collection_label
sub collectionLabel {
    my($self,$name) = @_;

    require EatHappy::Legacy::Config;
    #TODO: Why this no use collection object instantiated onece...
    my $conf = EatHappy::Legacy::Config->new(dataset => ($name || $self->{dataset}));
    #return $conf->collection_label;
    # TODO:  When coming from the page where we're doing a Collections->list, this thing
    # has no fucking data?!??!??!?!??,  BAKED IN MAYbE?!?!?
      die(Data::Dumper->Dump([$conf])) ;

	return $conf->collection_label;

      #die(Data::Dumper->Dump([$conf, $conf->collection_label])) unless ref($conf) =~ /Dataset/;

}
# For Publisher.pm, its files
sub publish_resource_dir {
    my($self) = @_;

    unless ($self->dataset_path) {
        $self->{error} = 'No "dataset_path" option';
        return;
    }

    return join('/', $self->dataset_path, 'Publish');
}

# Used by the index page
# Pull the logo &c up
sub online_template_args {
    my($self, %opts) = @_;

    # Pulled up from config...
    return map {$_ => $self->{$_}} qw(background logo logo_alt);

}
sub _file_to_list {
    my($self, $file) = @_;

    my $path = join('/', $self->dataset_path, $file);

    open my $in, "<", $path or confess "Couldn't open data file $file in $path\n";

    my @list;

    while (<$in>) {
        chomp;
        push(@list, $_);
    }
    close $in;

    return @list;
}

sub _remap_cat {
    my($self, $cat, $type) = @_;
    return      {
            categoryName => $cat, # Internal
            # TODO: not existing yet
            categoryLabel => $cat, # display
            categoryType => $type,
        }
}


return 1;
