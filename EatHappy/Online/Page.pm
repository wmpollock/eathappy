
package EatHappy::Online::Page;
use strict;

# ===============================================================
#   ___         __                    ___    __        __   ___
#  |__  |__| ../  \ |\ | |    | |\ | |__  ..|__)  /\  / _` |__
#  |___ |  | ..\__/ | \| |___ | | \| |___ ..|    /~~\ \__> |___
#
# ===============================================================

use CGI qw(:all);
use EatHappy::Online;

use parent "EatHappy::Base";
use parent 'EatHappy::Online';

sub render {
    my ($self, $content, %params) = @_;

    my $args = $self->get_args;

    $self = $self->new unless ref($self);    # allow instantiationless

    require EatHappy::Collections;

    my $outer_t = $self->outer_template;

    $outer_t->param(
        %params,
        %{$args},
        content  => $content,
        revision => EatHappy::Online::REVISION(),

        collection_loop => [
            map {
                {
                 collectionLabel => $_->collectionLabel,

             # I dunno about this shit, yo.  I miss dataset. [BP -- 23 Sep 2017]
                 collectionName => $_->collectionName,

                 # Kinda suss to generate it from an obj like thus:
                 # maybe s/b better in the object but /so online/
                 collectionUrl => $self->self_link(
                      url_only       => 1,
                      unfuck         => 1,                    # a useful switch?
                      view           => $args->{view},
                      collectionName => $_->collectionName,
                      dataset        => $_->collectionName,
                                                  ),
                }
              } EatHappy::Collections->list
        ],
    );

    print header(), $outer_t->output;
}

sub outer_template {
    my ($self) = @_;
    my $t = $self->template("Templates/standard.tmpl");    # TODO -- Config

    $t->param(outer_template => 1);

    # Moar nonsense that seems poorly placed
    $t->param(
        view_primary_category =>
          $self->self_link(view => 'by-category', url_only => 1, bullshit => 1),
        view_secondary_category =>
          $self->self_link(view => 'by-secondary', url_only => 1),
        view_all       => $self->self_link(view => 'view-all', url_only => 1),
        new_entry_link => $self->new_entry_link(),
    );

    return $t;
}

sub template {
    my ($self, $template, %params) = @_;
    require HTML::Template::Expr;
    my $t = HTML::Template::Expr->new(
                                      filename          => $template,
                                      die_on_bad_params => 0,
                                      loop_context_vars => 1,
                                     );

    my $args = $self->get_args;

    require EatHappy::Collection;

    my $collection = EatHappy::Collection->new(%{$args});

    $t->param(
        copyright_year  => ([localtime]->[5] + 1900),
        collectionLabel => $collection->collectionLabel,

        %params
             );

    return ($t);
}

sub recipe_template {
    my ($self) = @_;

    # TODO -- Config
    $self->template("Templates/recipe.tmpl");
}

sub index_template {
    my ($self) = @_;

    # TODO -- Config.  Ticket 555681
    $self->template("Templates/index.tmpl");
}

sub secondary_category_template {
    my ($self) = @_;

    # TODO -- Config.  Ticket 555681
    $self->template("Templates/index-entry-loop.tmpl");
}

sub editor_template {
    my ($self) = @_;

    # TODO -- Config
    $self->template('Templates/editor.tmpl');
}

return 1;
