package EatHappy::Base::FileSystemMethods;

use strict;
use Carp;

use constant DATA_DIR => ($ENV{DOCUMENT_ROOT} || ($ENV{HOME} . "/billpollock.com")) . "/eathappy/data";

sub dataset_path {
    my ($self, %args) = @_;

    $self = {} unless ref($self);

    my $dataset = $args{dataset} || $self->{dataset} || $args{collectionName} || $self->{collectionName};

    use Data::Dumper;
    confess("Failed to find dataset from below (no dataset or CollectionName):\n", Data::Dumper->Dump([$self, \%args]))
      unless $dataset;

    return join('/', DATA_DIR, $dataset);
}

return 1;
