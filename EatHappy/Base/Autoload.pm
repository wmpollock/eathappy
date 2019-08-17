package EatHappy::Base::Autoload;

use strict;

# DEPRECATED: Probably use Class::Accessor instead

sub AUTOLOAD {
    my ($self, @args) = @_F;
    our $AUTOLOAD;

    (my $method = $AUTOLOAD) =~ s/.+:://;

    if ($method =~ /^set_(.+)/) {
        $self->{$1} = $args[0];
    } else {
        if ($self->{$method} =~ /ARRAY/) {
            return @{$self->{$method}};    # its an autodumper, yo!
        } else {
            return $self->{$method};       # its an autodumper, yo!
        }
    }
}

return 1;
