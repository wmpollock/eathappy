package EatHappy::Base;

# Perhaps if only to save us for new():

use strict;

use Carp;

sub new {
    my ($class, %opts) = @_;
    confess if ref($class);

    my $self = bless \%opts, $class;

    return $self;
}

return 1;
