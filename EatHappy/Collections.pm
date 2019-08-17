#
#   _____     _   _____                 _ _ _____     _ _         _   _
#  |   __|___| |_|  |  |___ ___ ___ _ _|_|_|     |___| | |___ ___| |_|_|___ ___ ___
#  |   __| .'|  _|     | .'| . | . | | |_ _|   --| . | | | -_|  _|  _| | . |   |_ -|
#  |_____|__,|_| |__|__|__,|  _|  _|_  |_|_|_____|___|_|_|___|___|_| |_|___|_|_|___|
#                          |_| |_| |___|

package EatHappy::Collections;

# EatHappy::Collections - Container for all available collections
# [BP -- 2015]
# ---------------------------------------------------------------------------

use strict;

use parent 'EatHappy::Base';
use parent "EatHappy::Base::Autoload";

use EatHappy::Collection;

sub list {
    my($package, %opts) = @_;

    # TODO: de-legacy
    require EatHappy::Legacy::Config;


    map {$_->{collectionLabel} = $_->{title}; # LEGACY BRIDGE
	   EatHappy::Collection->new(%{$_})
	 } EatHappy::Legacy::Config->collections();
}

sub default {
    my($package, %opts) = @_;

    return grep($_->{default}, $package->list(%opts));
}

return 1;
