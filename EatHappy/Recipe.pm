package EatHappy::Recipe;

# TODO: Be nicer to live in an XML/Save method. [BP --  6 Jul 2013]
use XML::Node;
use XML::Twig;

use Carp;
use strict;

use parent "EatHappy::Base::FileSystemMethods";
use parent 'Class::Accessor';

#used internally
sub new {
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;
    return $self;
}

sub is_new {
    my ($entry) = @_;
    return $entry->new_entry;
}

sub is_untried {
    my ($entry) = @_;
    return $entry->untried;
}

sub add_ingredient {
    my ($entry, %ingredient) = @_;
    push(@{$entry->{ingredients}}, \%ingredient);    # cheap
}

sub is_updated {
    my ($entry) = @_;
}

sub save {
    my ($self) = @_;

    require EatHappy::Recipe::XML;
    my $x = EatHappy::Recipe::XML->new(%{$self});
    $x->save;
    return $x;
}

sub load {
    my ($self, $args) = @_;
    require EatHappy::Recipe::XML;
    $self = $self =~ /HASH/ ? $self : {};
    my $x = EatHappy::Recipe::XML->new(%{$self});
    my $r = $x->load($args);

    # Some add'l methods need adding as if not there, whoops...
    # prolly should do master list but ..?
    EatHappy::Recipe->mk_accessors(keys %{$r}, 'untried', 'new_entry');

    return $r;

}

# LAbel is the string, name is used for URLs.  I know everybody loves IDs
# but google loves names
sub recipeName {
    my ($self) = @_;

    return $self->{recipeName} if $self->{recipeName};

    my ($name) = (
             $self->{recipeLabel}
          || $self
          ->{name} # LEGACY, probably in XML but shouldn't be ocming down. [BP -- 15 Feb 2015]
    );

    unless {
        use Data::Dumper;
        confess("No name: ", Data::Dumper->Dump([$self]));
           }

      $name =~ s/\'//g;
    $name =~ s/\W/-/g;    # } - used to be underscore [BP -- 15 Feb 2015]
    $name =~ s/-+/-/g;    # }

    $name or die "NO NAME: $name";

    $self->{recipeName} = $name;
    return $name;
}

return 1;
