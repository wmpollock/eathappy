#!/usr/bin/perl

# Because we got more sensible about how the indexes were stored in their last days (real-time)
# there wasn't a per-entry use for a rebuilder and it fell behind the times.
# [BP -- 15 Jan 2016]
#---------------------------------------------------------------------------

use strict;
use lib "../";
use EatHappy::Collections;
use EatHappy::Collection::XML;

foreach my $collection (EatHappy::Collections->list) {
    print "Rebuilding ", $collection->collectionLabel, "\n";

    EatHappy::Collection::XML->rebuild_index(%{$collection}, verbose => 1);
}
