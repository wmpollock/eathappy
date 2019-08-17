package EatHappy::Online::Args;

use strict;
use Carp;
use CGI qw(:all);

sub new {
    my ($class, %opts) = @_;

    my $self = bless %opts, $class;

    return $self;
}

sub is_view_all {
    my ($self) = @_;
    return $self->{view} eq 'view-all';
}

sub is_by_category {
    my ($self) = @_;
    return $self->{view} eq 'by-category';
}

sub is_by_secondary {
    my ($self) = @_;
    return $self->{'view'} eq 'by-secondary';
}

sub get_args {
    my ($class, %base_args) = @_;

    # URL arguments are:
    # /mode/collection/view/(category/)?recipeName
    my $args = {};

    if (!$base_args{ignore_url}) {
        my ($mode, $collection, $view, @vargs);
        if ($ENV{SCRIPT_URI} =~ m-/((?:show|list|edit|save)/.+)-) {
            ($mode, $collection, $view, @vargs) = split(m-/-, $1);
        }
        my ($category, $subcategory, $recipeName);
        if ($view eq 'by-secondary') {

            # Though we may not see $recipeName coming in in a subcategory list
            ($subcategory, $recipeName) = @vargs;
        } elsif ($#vargs == 1) {
            ($category, $recipeName) = @vargs;
        } elsif ($#vargs == 0) {
            ($recipeName) = @vargs;
        }

        # Saving ->making
        if (param('Submit')) {
            $collection ||= param('collectionName');
            $recipeName ||= param('recipeName');
        }

        $args = {
            mode       => $mode,
            dataset    => $collection,    # decpreciated
            collection => $collection,    # also deprecated, oh but maybe not :(
            collectionName     => $collection,
            view               => $view,           # preferred
            category           => $category,
            subcategory        => $subcategory,    # deprecated
            secondary_category => $subcategory,
            entry              => $recipeName,     # DEPRECATED
            recipeName         => $recipeName,

		    # Override with supplied since the user is always right. [BP -- 24 Jan 2015]
            %base_args,
                };
    } else {
        $args = \%base_args;
    }

    # Set some hard defaults in case I'm half-assing the URL
    # TODO, default category, etc. [BP -- 18 Jan 2015]
    # ticket 137616
    foreach my $arg_pair (
        [mode => 'show'],
        [view => 'by-category']
      ) {
        $args->{$arg_pair->[0]} ||= $arg_pair->[1];
    }

    return (bless($args, $class));
}

our $AUTOLOAD;

sub AUTOLOAD {
    my ($self) = @_;
    my $method = $AUTOLOAD;
    $method =~ s/.*:://;
    if ($method =~
        /^(category|collection|secondary_category|recipeName|mode|view)$/) {
        return $self->{$method};
    } elsif ($method =~ /^(dataset|entry|subcategory|view)$/) {

#TOD: these are all decprecated and should b ea big ol' die to ferret out. [BP -- 15 Feb 2015]
        return $self->{$method};
    } else {
        confess "No method $method";
    }

}

return 1;
