#!/usr/bin/perl

# Build basic schema files for DBIx::Class

use strict;

# http://search.cpan.org/~ilmari/DBIx-Class-Schema-Loader-0.07045/lib/DBIx/Class/Schema/Loader.pm

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

make_schema_at(
    "EatHappy::DBIx",
    {dump_directory => './lib'},
    [
        #$dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";
        "DBI:mysql:database=eathappy;host=mysql.billpollock.com",
        'eathappy',
        'XvT2msZv89bM9nu8',
    ]

);
