#   ___         __        __          __          __  ___  ___
#  |__  |__| ..|__) |  | |__) |    | /__` |__| ..|__)  |  |__
#  |___ |  | ..|    \__/ |__) |___ | .__/ |  | ..|  \  |  |
#

package EatHappy::Publish::RTF;

use strict;
use Carp;

use lib "$ENV{HOME}/billpollock.com/eathappy";
use parent "EatHappy::Base";

use EatHappy::Collection;
use EatHappy::Recipe;

use lib "$ENV{HOME}/billpollock.com/Common/Perllib";
use Publisher::RTF;

# TODO -- maybe allow config?
use constant ICON_WIDTH_INCHES  => '.75';
use constant ICON_HEIGHT_INCHES => '.58';

# TODO -- maybe allow config?
use constant INGREDIENT_COL1_WIDTH_INCHES => 1;               # SRSLY?
use constant NO_DELETED                   => 'NO DELETED';    # Seems reasonable ?!?!

use constant ICON_DIR => "$ENV{HOME}/billpollock.com/eathappy/Publishing/Resources/";

# MACROS BE LAME, YO.
sub BEGIN {
    sub _icon {return join('/', ICON_DIR, $_[0]);}
}

use constant ICON_UNTRIED_SOURCE => _icon('UntriedIcon.PubQuality.png');
use constant ICON_NEW_SOURCE     => _icon('NewIcon.PubQuality.png');

# make a cookbook
sub format_collection {
    my ($self, %opts) = @_;

    my $collection = EatHappy::Collection->new(%opts);    # passthrough collectionName

    my $public_resource_dir = $collection->publish_resource_dir;

    -e $public_resource_dir
      or die "FATAL: publisher wants $public_resource_dir or a lot of arguments you aren't passing son'boy.";

    my $book_args = $self->{book_args} ||= {
                                            publish_resource_dir => $public_resource_dir,
                                            %opts,
                                           };

    my $book = $self->{book} = Publisher::RTF->new(%{$book_args});

    #TODO: This appears to add blank page?!?
    $book->title_page;
    $book->copyright_page;

    #TODO: This appears to add blank page?!?
    $book->start_page_numbering;
    $book->aux_content('Introduction');

    $self->{icon_untried} = $book->image(filename => ICON_UNTRIED_SOURCE);

    $self->{icon_new} = $book->image(filename => ICON_NEW_SOURCE);

    my $count = 0;

    my $sort = $book->publishing_info('sort')
      || 'title';    # alternate value: primary category, title
    my $last_category;
    foreach my $entry (
                       $collection->entries(
                                            sort   => $sort,
                                            limits => [NO_DELETED]
                                           ),
      ) {

        if (    $sort eq 'primary category'
            and $last_category ne $entry->primary_category) {
            $last_category = $entry->primary_category;
            $book->Page;
            $book->subtitle_page(title => $entry->primary_category);
            $book->start_page_numbering(left_footer => $entry->primary_category);

        }

        $self->format_entry($entry);

        if ($book_args->{limit_pages}) {
            if (++$count == $book_args->{limit_pages}) {
                last;
            }
        }
    }

    $book->bibliography_page;

    # TODO: This should come from the configuration
    $book->notes_page(2);

    $book->index_page;

    $book->finish;

    return (1);
}

sub format_entry {
    my ($self, $entry_args) = @_;

    my $book = $self->{book}
      or confess "FATAL: object doesn't have a 'book' element.";
    my $ehe = EatHappy::Recipe->new;

    my $entry = $ehe->load($entry_args);

    my %entry_args = (
                      title         => $entry->name,
                      primary_index => sprintf("%s:%s", $entry->primary_category || 'Uncategorized', $entry->name)
                     );

    foreach my $secondary (@{$entry->secondary_categories || []}) {
        push(@{$entry_args{standard_indexes}}, sprintf("%s:%s", $secondary, $entry->name));
    }

    $book->new_entry(%entry_args);

    # TODO:  Make this conditional on the output(!)
    if ($entry->is_untried) {

        #ADD        $book->page_icon($self->{icon_untried},
        #ADD                         ICON_WIDTH_INCHES
        #ADD            );
    }

    if ($entry->is_new) {

        #ADD        $book->page_icon($self->{icon_new},
        #ADD                         ICON_WIDTH_INCHES
        #ADD            );
    }

    if ($entry->yield_count) {
        $book->paragraph($book->italic('Yield:'), $entry->yield_count, ' ', $entry->yield_measure);
    }

    if ($entry->prep_time) {
        $book->paragraph($book->italic('Prep time:'), $entry->prep_time,);
    }

    if ($entry->notes) {
        $book->paragraph($book->linebreak);

        $book->note_paragraph($entry->notes);
    }

    if ($entry->ingredients) {
        $book->paragraph($book->linebreak, $book->bold('Ingredients:'));

        my $ingredient_table = $book->new_table(1, '*');

        foreach my $ingred (@{$entry->ingredients}) {
            if ($ingred->{ingredient_name} =~ /^\*\*(.+)/) {
                $ingred->{ingredient_section} = $1;
                $book->paragraph($book->bold($book->underline($ingred->{ingredient_section})));
            } else {
                my $last_cell = $ingred->{ingredient_name};
                if ($ingred->{preparation}) {
                    $last_cell .= ', ' if ($last_cell);
                    $last_cell .= $ingred->{preparation};
                }
                $book->row($ingredient_table, $ingred->{quantity}, $last_cell);
            }
        }
    }

    if ($entry->preparation) {
        $book->paragraph($book->linebreak, $book->bold('Preparation:'));
        $book->paragraph($entry->preparation);
    }

    if ($entry->source_name) {

        # TODO: Use config to skip pieces (E.g. page for gramma);
        my $source = $book->endnote($book->bold('Source: '), $entry->source_name);
    }
}

sub publish_resource_dir {
    my ($self, $collection) = @_;

    unless ($self->dataset_path) {
        $self->{error} = 'No "dataset_path" option';
        return;
    }

    return join('/', $self->dataset_path, 'Publish');
}

return 1;

