package EatHappy::Online;
use strict;

#   _____     _   _____                 _ _ _____     _ _
#  |   __|___| |_|  |  |___ ___ ___ _ _|_|_|     |___| |_|___ ___
#  |   __| .'|  _|     | .'| . | . | | |_ _|  |  |   | | |   | -_|
#  |_____|__,|_| |__|__|__,|  _|  _|_  |_|_|_____|_|_|_|_|_|_|___|
#                          |_| |_| |___|
# Pollock, 2015->
# http://patorjk.com/software/taag/#p=display&f=Rectangles&t=EatHappy%3A%3AOnline

# Fun hings for the future:

# forward on save
#* json export
#* rtf export
#*

use EatHappy::Online::Page;

use CGI qw(:all);
use Carp;

# TODO:  THESE ARE HERE BUT CLEARLY NEED FACTORING ELSE [BP -- 24 Jan 2015]
# ticket 154951
use constant PRIMARY_CATEGORY => 'primary category';
use constant DEFAULT_VIEW     => 'name';
use constant REVISION         => ('$Revision: 1.58 $' =~ /(\d+\.\d+)/)
  ;    # Nec. for Online::Page

#===========================================================================
#         ___ ___       __   __   __    /        __   __   ___  __
#   |\/| |__   |  |__| /  \ |  \ /__`  /   |\/| /  \ |  \ |__  /__`
#   |  | |___  |  |  | \__/ |__/ .__/ /    |  | \__/ |__/ |___ .__/
#
#===========================================================================

sub new {
    my ($class, %opts) = @_;

    my $self = bless \%opts, $class;

    return $self;
}

# Legacy invocation
sub render_recipe {show(@_)}

# /show , new form -- API SHOULD == URL METHODS, DAMNIT
sub show {

    # TODO: unfurck this shit
    # asww, I dunno -- show means seeral things :/ [BP -- 23 Sep 2017]
    my ($self, $recipeName) = @_;

    require EatHappy::Recipe;

    my $args = $self->get_args;

    my $t     = EatHappy::Online::Page->recipe_template;
    my $entry = EatHappy::Recipe->load($args);

    if ($self->mode('save')) {
        $t->param('entry_saved' => 1);
    }

    $entry->{preparation} =
      join("\n", map {p($_)} split(/(?:\s*\n\s*)+/, $entry->preparation));

    $t->param(%{$entry});

    if (0) {
        use Data::Dumper;
        die(
            Data::Dumper->Dump(
                [
                 {
                  ignore_url => 1,
                  mode       => 'list',
                  dataset    => $entry->dataset,
                  view       => 'by-category',
                  name       => $entry->primary_category,

                  #							category => $entry->primary_category,
                  #							anchor => $entry->{entry_name}

                 }
                ]
            )
           );

    }

    # Link from the catgegory to the category list fully expanded and indexed
    $t->param(
        primary_category_link => $self->self_link(
            ignore_url => 1,
            mode       => 'show',
            dataset    => $entry->dataset,
            view       => 'by-category',
            name       => $entry->primary_category,    # for label

            #							category => $entry->primary_category,
            anchor => $entry->primary_category,

                                                 )
             );

    # TODO: constant here sucks, should be a "meta" type
    if (grep($_ eq "Bill's Favorite", @{$entry->{secondary_categories}})) {
        $t->param(favorite => 1);
    }

    # TODO:  secondary cateogires should be an object
    # Maybe they are?!?

    if (my $sc = $entry->{secondary_categories}) {
        $t->param(
            secondary_category_list => join(
                ', ',
                map ({
                        $self->self_link(
                            title              => $_,
                            mode               => 'show',
                            view               => 'by-secondary',
                            secondary_category => undef,

                            # morew like this tho....
                            anchor => $_
                                        )
                    } @{$sc})
            )
        );
    }

    EatHappy::Online::Page->render(
        $t->output,
        page_class => 'recipe',

        #recipe_page => 1,
        edit_link => $self->self_link(
                                      %{$entry},
                                      url_only => 1,
                                      mode     => 'edit'
                                     ),
                                  );
}

sub render_index {
    my ($self) = @_;
    my $args = $self->get_args;

    my $t =
      $args->secondary_category
      ? EatHappy::Online::Page->secondary_category_template
      : EatHappy::Online::Page->index_template;

    my %view_name = (
                     'by-category'  => 'Primary Categories',
                     'by-secondary' => 'Secondary Categories',
                     'view-all'     => 'All Entries',
                    );

    my $view_name = $view_name{$args->view};

    require EatHappy::Collection;
    my (@entry_loop);

    my $c = EatHappy::Collection->new(%{$args});

    $t->param($c->online_template_args);
    $t->param(%{$args});

    # TODO:  [BP -- 23 Sep 2017]
    my @index = $c->entries;

    my (%categories);

    foreach my $entry (@index) {
        $entry->{entry_link} =
          $self->self_link(
                %{$entry},
                (class => $args->{view} eq 'view-all' ? '' : 'list-group-item'),
                title => $entry->{name},
                mode  => 'show',
          );

        if ($args->is_view_all) {
            push(@entry_loop,
                 map {delete $_->{secondary_categories}; $_} $entry);
        } elsif ($args->is_by_category) {

# CASE ARGUMENT:  We're listing all the items available under the primary categories.  When the
# collectionName is small enough like it is now this is probably a better way fo doing it than
# banging back to the server for content.  That said, it doesn't scale super-great
# and probably should be dealt with in a consistent manner if only for the sake of
# code sanity. [BP -- 11 Feb 2015]
            my $cat = $entry->{primary_category};

            # Instantiation
            my $priEnt = $categories{$cat} ||= {name => $cat, categories => []};

            $priEnt->{count}++
              ;    #TODO, as an obj this would be calcuable [BP --  8 Feb 2015]

            push(@{$priEnt->{entries}}, _wash_entry($entry));

        } elsif ($args->is_by_secondary) {

# We've got two caes here:
# 1) We're listing all the secondary
# 2) returning the data for teh specified category.  This should be from a restricted
# collectionName
            $t->param(view_secondary_categories => 1)
              ;    # TODO, this should be in an EXPR against $args

            foreach my $secondary ($entry->secondary_categories) {
                my $secEnt = $categories{$secondary} ||= {name => $secondary};
                $secEnt->{count}++;

                if ($args->secondary_category eq $secondary) {
                    push(@entry_loop, $entry);
                }
            }

        } else {
            die "DAMN.";
        }
    }

    $t->param(index_title => $view_name);

    # WTF?!?!!?!? Where args from
    #    $t->param(logo => $args->{logo});

# Pull the defined category sort so we can do smarter things than just alpha... [BP -- 20 Sep 2017]
    if ($args->is_by_secondary) {
        $t->param(
                 category_loop => [map {$categories{$_}} sort keys %categories])
          if %categories;
    } else {
        $t->param(
                  category_loop => [
                                 map {$categories{$_->{categoryName}}}
                                   grep(defined $categories{$_->{categoryName}},
                                        $c->primary_categories)
                                   ]
                 );
    }

    $t->param(entry_loop => [sort {$a->{name} cmp $b->{name}} @entry_loop])
      if @entry_loop;

    if ($args->secondary_category and $args->mode eq 'list') {
        print header(), $t->output;

    } else {
        EatHappy::Online::Page->render(
                                       $t->output,
                                       page_class => 'index_page',
                                       index_page => 1
                                      );
    }
    exit;

}

sub render_editor {
    my ($self) = @_;

    my $args = $self->get_args;

    my $is_new_entry;

    my $entry;

    if ($args->{'entry'}) {
        $is_new_entry = 0;
        require EatHappy::Recipe;
        $entry = EatHappy::Recipe->load($args);
    } else {
        $is_new_entry = 1;
        $entry        = {%{$args}};    # Cheap cast.
    }

    my $t = EatHappy::Online::Page->editor_template;

    require EatHappy::Collection;
    my $collection = EatHappy::Collection->new(%{$entry}, %{$args});

    $t->param(
              %{$collection},
              category_loop           => [sort $collection->primary_categories],
              secondary_category_loop => [$collection->secondary_categories],
              %{$entry},
             );

    require JSON::PP;
    import JSON::PP;
    my $json = JSON::PP->new->pretty;

    $t->param(formState => $json->encode({%{$entry}}));

    EatHappy::Online::Page->render(
        $t->output,
        page_class => 'editor',

        # editor_page => 1,
                                  );
}

sub render_save {
    my ($self) = @_;

    # Now we've got to build the form
    use Tie::IxHash;
    tie my %data, 'Tie::IxHash';

    my $entry;
    if (param('original_name')) {
        require EatHappy::Recipe;
        my $recargs = {
                       recipeName => param('original_name'),
                       map {$_ => param($_)} qw(collectionName)
                      };
        $entry = EatHappy::Recipe->load($recargs);
        $data{originalRecipeName} = param('original_name');
    }

    _xfer_param(\%data,
                qw(collectionName recipeLabel primary_category untried));
    $data{secondary_categories} = [param('secondary_categories')];
    _xfer_param(\%data, qw(yieldQuant yieldUnit prepTime notes));

    my %tdata;

# ~~ measureQautn should be ingredQuant since measureQuant needs like some parsing.
    foreach my $bit (qw(measureQuant ingredientName ingredientPrepName)) {
        @{$tdata{$bit}} = param($bit);
    }

    while (@{$tdata{ingredientName}}) {
        tie my %ingredients, 'Tie::IxHash',
          (
            quantity        => shift @{$tdata{measureQuant}},
            ingredient_name => shift @{$tdata{ingredientName}},
            preparation     => shift @{$tdata{ingredientPrepName}}
          );

        # Stop pushing null records! [BP -- 10 Jun 2007]
        if (grep $_, values %ingredients) {
            push(@{$data{ingredients}}, \%ingredients);
        }
    }

    _xfer_param(\%data,
                qw(preparation sourceAuthor sourceTitle sourcePage sourceDate));

    $data{entry_app} = 'EH 3.0';
    my @date = localtime time;

    # yeahhh, man, more ISO, gwoan be a mess up in there
    my $today =
      sprintf("%4.4d-%2.2d-%2.2d", $date[5] + 1900, $date[4] + 1, $date[3]);

    if ($entry->{cdate}) {
        $data{mdate} = $today;
    } else {
        $data{cdate} = $today;
    }

    $data{user} = $ENV{REMOTE_USER};

    require EatHappy::Recipe;

    my $er = EatHappy::Recipe->new(%data);

    if (my ($x) = $er->save) {

        param('recipeName', $x->recipeName);
        $self->render_recipe;

        exit;

    } else {
        die "FATAL: unable to save -- ", $er->save;
    }

}

#       ___          ___               ___ ___       __   __   __
#  |  |  |  | |    |  |  \ /     |\/| |__   |  |__| /  \ |  \ /__`
#  \__/  |  | |___ |  |   |      |  | |___  |  |  | \__/ |__/ .__/
#

sub get_args {
    my ($self, %base_args) = @_;
    require EatHappy::Online::Args;
    $self = {} unless ref($self);    # Pad it over, who cares.
    $self->{args} ||= return EatHappy::Online::Args->get_args(%base_args);
    return $self->{args};
}

sub mode {
    my ($self, $modeTest) = @_;
    my $args = $self->get_args;

    if ($modeTest) {
        return $modeTest eq $args->{mode};
    } else {
        return $args->{mode};
    }
}

sub self_link {
    my ($self, %opts) = (@_);

    my $args = $self->get_args(%opts);

    $args->{mode} = 'show'
      if $args->{mode} eq 'save';    # Fix all the links from the save page.

    my %skip;
    if ($args->{skip} =~ /ARRAY/) {
        %skip = map {$_ => 1} @{$args->{skip}};
    } elsif ($args->{skip}) {
        die;
    }

    my ($title, $script_name, $collectionName, $url) =
      map {$args->{$_}} qw(title script_name collectionName use_url);

    unless ($url) {

        my @args = map {confess "no $_" unless $args->{$_}; $args->{$_}}

          # qw(mode collectionName view );
          qw(mode dataset view );

        # FUCK THIS collectionName thing I think. [BP -- 23 Sep 2017]

        # Tempting to make @args more conditional but visible failure on
        # assumed elements is better than a clean failure. [BP -- 24 Jan 2015]
        $args->{entry_name} ||= $args->{safe_name}
          ; # TODO -- index is askew and s/b showing safe_name (maybe is...) [BP -- 25 Jan 2015]
        foreach (qw(category secondary_category entry_name)) {

            push(@args, $args->{$_}) if ($args->{$_});
        }
        $url = join('/', '/eathappy', @args);
    }

    ($url .= "#$args->{anchor}") if ($args->{anchor});

    return $url if ($opts{url_only});

    my %href_opts = (-href => $url);

    if ($args->{anchor_name}) {
        $href_opts{name} = $args->{anchor_name};
    }

    # STANDARIZE TO CGI.pm these days -- just pass args through
    foreach my $arg (qw(class id style)) {
        $href_opts{$arg} = $args->{$arg} if $args->{$arg};
    }

    my $cont = $args->{name} || $args->{title} || $opts{name};
    $cont ||= '??MISSING??';

    unless ($cont) {
        require Data::Dumper;
        confess("FATAL: no link content", Data::Dumper->Dump([$args]));
    }

    return a(\%href_opts, $cont);
}

#sub sort_link {
#    my($self,%opts) = @_;
#    require URI::Escape;
#    import URI::Escape qw(uri_escape);

#    $opts{mode} = 'sort';
#    $opts{view} = uri_escape($opts{view}); # TODO : WHY?!?
#    return $self->self_link(%opts);
#}

sub new_entry_link {
    my ($self) = @_;
    $self->self_link(url_only => 1,
                     mode     => 'edit');
}

sub _wash_entry {
    my ($entry) = @_;
    return {
            map {$_ => $entry->{$_}}
            grep($_ !~ /secondary_categories/, keys %{$entry})
           };
}

sub _xfer_param {
    my ($data, @labels) = @_;
    foreach my $label (@labels) {
        my $ucont = param($label);
        $ucont =~ s/\r//;
        $data->{$label} = $ucont if $ucont;
    }
}

return 1;
