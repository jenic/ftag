#!/usr/bin/perl
use strict;
use Storable qw(lock_store lock_retrieve);
use Getopt::Std;
use Cwd qw(cwd);
require "/home/jenic/Projects/Debug/lib/Debug.pm";

use constant {
    _DB => $ENV{HOME} . '/.tags.db',
};

sub save;
sub getTags;

my %db;
our %opts;
my $cwd = cwd();
$Getopt::Std::STANDARD_HELP_VERSION = 1;

getopts('vid:t:f:', \%opts);
$opts{d} = _DB unless exists $opts{d};
$Debug::ENABLED = 0 unless exists $opts{v};

while (my ($k, $v) = each %opts) {
    Debug::msg("Have $k => $v\n");
}

save() unless (-e $opts{d});
%db = %{ lock_retrieve($opts{d}) };

if (exists $opts{t} && exists $opts{f}) {
    # Adding a tag
    for my $tag (getTags()) {
        Debug::msg("Got $tag");
        $db{$tag} = {} unless exists $db{$tag};
        $db{$tag}{"$cwd/$opts{f}"}++;
    }
    save();
} elsif (exists $opts{t}) {
    # Looking for files with tags
    # TODO: intersection
    # http://docstore.mik.ua/orelly/perl/cookbook/ch04_09.htm
    for my $tag (getTags()) {
        if (exists $db{$tag}) {
            print "$tag:\n";
            for (keys %{$db{$tag}}) {
                print "\t$_\n";
            }
        }
    }
} elsif (exists $opts{f}) {
    # What tags does this file have?
    my $file = "$cwd/$opts{f}";
    my @tags;
    for my $tag (keys %db) {
        if (exists $db{$tag}{$file}) {
            push @tags, $tag;
        }
    }
    print "$file tags: @tags\n";
} else {
    # Default, show all tags
    while (my ($k, $v) = each %db) {
        printf "%s: %i tags\n",
        $k, scalar keys %{$v};
    }
}

sub save {
    lock_store \%db, $opts{d} or die "E: $!\n";
}

sub getTags {
    return split ',', shift || $opts{t};
}

sub HELP_MESSAGE {
    print <<EOF;
Syntax: tag [ -t <tag1,tag2,...> | -f <file.name> ] | [-v] [-d <file>]
If -t and -f are found in same runtime it is assumed you are tagging a file.
-v  Verbose output
-d  Specify database file, default is ~/.tags.db
EOF
}
