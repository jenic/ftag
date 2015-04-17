#!/usr/bin/perl -w
use strict;
use Storable qw(lock_store lock_retrieve);
use Getopt::Std;
use Cwd qw(cwd);
require "/home/jenic/Projects/Debug/lib/Debug.pm";
# Yes I know Debug is used only once...stfu
no warnings qw(once);

use constant {
    _DB => $ENV{HOME} . '/.tags.db',
};

sub save;
sub getItems;

my %db;
our %opts;
my $cwd = cwd();
$Getopt::Std::STANDARD_HELP_VERSION = 1;

getopt('vid:t:f:', \%opts);
$opts{d} = _DB unless exists $opts{d};
$Debug::ENABLED = 0 unless exists $opts{v};

while (my ($k, $v) = each %opts) {
    Debug::msg("Have $k => $v\n");
}

save() unless (-e $opts{d});
%db = %{ lock_retrieve($opts{d}) };

if (exists $opts{t} && exists $opts{f}) {
    # Adding a tag
    for my $file (getItems($opts{f})) {
        for my $tag (getItems($opts{t})) {
            Debug::msg("Got $tag");
            $db{$tag} = {} unless exists $db{$tag};
            $db{$tag}{"$cwd/$file"}++;
        }
    }
    save();
} elsif (exists $opts{t}) {
    # Looking for files with tags
    # TODO: intersection
    # http://docstore.mik.ua/orelly/perl/cookbook/ch04_09.htm
    for my $tag (getItems($opts{t})) {
        if (exists $db{$tag}) {
            print "$tag:\n";
            for (keys %{$db{$tag}}) {
                print "\t$_\n";
            }
        }
    }
} elsif (exists $opts{f}) {
    # What tags does this file have?
    for my $file (getItems($opts{f})) {
        # Absolute or relative path?
        my $f = ($file !~ /^\//) ? "$cwd/$file" : $file;
        my @tags;
        for my $tag (keys %db) {
            if (exists $db{$tag}{$f}) {
                push @tags, $tag;
            }
        }
        print "$f tags: @tags\n";
    }
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

sub getItems {
    return split ',', shift || $opts{t};
}

sub HELP_MESSAGE {
    print <<EOF;
Syntax: tag [ -t <tag1,tag2,...> | -f <file1,file2,...> ] | [-v] [-d <file>]
If -t and -f are found in same runtime it is assumed you are tagging a file.
-v  Verbose output
-d  Specify database file, default is ~/.tags.db
EOF
}
