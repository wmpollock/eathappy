package EatHappy::Legacy::Config;
use strict;
use Carp;

#   ___             ___  __        __        __   __        ___    __
#  |__  |__|..|    |__  / _`  /\  /  ` \ /../  ` /  \ |\ | |__  | / _`
#  |___ |  |..|___ |___ \__> /~~\ \__,  | ..\__, \__/ | \| |    | \__>
#

# TODO:  I sure hope nothing is calling this directly other than like Eathatppy::Config
# on preview: no :/ [BP -- 23 Sep 2017]

# Dash off some fo the configuration that I'd like to get into a DB?!? at some point

# [BP -- 23 Sep 2017] now, from the future, maybe not so much :/  Maybe all in XML
#  All in /something/ would be nice, the migration to Publisher aside...

use Tie::IxHash;

# This is sweet for lookup but not so sweet for DB representation.
# Datasets will force the key back into the label
  tie my %collections, 'Tie::IxHash', (
    '4th-edition' => {
                      collection_label => 'Eat Happy: 4th Edition',
                      new              => '**New14',
                      deleted          => '**Deleted14',
                      start_date       => '20140127',
                      view             => 1,
                      editors          => 'billp',
                      default          => 1,
                     },
    gramma => {
        collection_label => 'Dr. Leta Jackson\'s Cooking Omnibus',
        view             => 1,
        editors          => 'billp',
        new              => 'NONE?!?!?',
        background       => '/eathappy/data/gramma/Publish/leather-book.jpg',
     #	logo => '/eathappy/data/gramma/Publish/Leta_Jackson_at_the_Dining_Table.jpg',
        logo =>
'/eathappy/data/gramma/Publish/Leta_Jackson_at_the_Dining_Table_-_Recropped.jpg',
        logo_alt => 'Gum at the dining room table, ca????',
              },

    pollock => {
        collection_label => 'Pollock Family Cookbook',
        view             => 1,
        editors          => '*',
        new              => 'NONE?!?!?',

               },

    'hilary' => {
                 collection_label => "Hilary's Collection",
                 new              => '**New06',
                 start_date       => '20050127',
                 view             => 1,
                 editors          => 'billp,hilaryp',
                },

    # Farewell, old collections. [BP -- 13 Aug 2018]
    #    '3rded' => {
    #        collection_label => 'Eat Happy: 3rd Edition',
    #        new => '**New06',
    #        deleted => '**Deleted06',
    #        start_date => '20050127',
    #        view => 1,
    #        editors => 'billp',
    #	legacy => 1,
    #    },
    #    'v2' => {
    #	collection_label => 'Eat Happy: 2nd Edition',
    #	new => '**New05',
    #	view => 0,
    #	editors => '',
    #	legacy => 1,
    #    },

    #LEGACY?!?!?
    #    'pollock05' => {
    #        collection_label => 'Pollock Family Cookbook',
    #        new => '**New06',
    #        start_date => '20050127',
    #        editors => 'billp',
    #    },
                                      );

sub new {
    my ($class, %opts) = @_;

    # Do I want a dataset or just methods (and WTF the latter?!?)
    # (awkward)
    if ($opts{dataset}) {
        %opts = (%{$collections{$opts{dataset}}}, %opts);

        return bless \%opts, "EatHappy::Config::Dataset";
    } else {

        return bless \%opts, $class;
    }

}

# Like rows, but less cool
sub collections {
    my ($self, %opts) = @_;

    return map {
        {
# Ugh, maybe -- was I obsoleting dataset maybe?? Seems shitty now... [BP -- 23 Sep 2017]
         collectionName => $_,

         # Seems more progressive... ;> [BP -- 23 Sep 2017]
         dataset => $_,
         %{$collections{$_}}
        }
    } keys %collections;
}

sub collection_config {
    my ($self, $dataset) = @_;
    $collections{$dataset} or die "No collectino for $dataset\n";
    return %{$collections{$dataset}};
}

# Object-oriented shizznit
package EatHappy::Config::Dataset;

sub collection_label {
    my ($self) = @_;
    return $self->{collection_label};
}

return 1;
