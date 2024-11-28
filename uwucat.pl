#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;

my $directory = '/var/log/uwuscan';

opendir(my $dh, $directory) or die "I can't o-open the catawog $!";

my @files = grep { -f "$directory/$_" } readdir($dh);

closedir($dh);

print "Files in the d-diwectowy:\n";
for my $index (0 .. $#files) {
    print "$index: $files[$index]\n";
}

print "Sewect the file number you want to use: ";
chomp(my $choice = <STDIN>);

if ($choice =~ /^\d+$/ && $choice >= 0 && $choice <= (scalar @files - 1)) {
    my $selected_file = "$directory/$files[$choice]";

    open(my $fh, '<', $selected_file) or die "I c-can't open the fiwe: $!";
    print "T-the contents o-of the fiwe:\n";

    while (my $line = <$fh>) {
        print $line;
    }

    close($fh);
} else {
    print "Wwong choice. Twy again.\n";
}
