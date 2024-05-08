#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use POSIX qw(strftime);
use File::Basename;

my $dir = '/var/uwuscan_log';
my $today = strftime "%a %b %e", localtime; # Date in the "Tue May 7" format

for my $log_file (glob "$dir/*") {
    # Checking the file to make sure that this file is the right file
    if (-f $log_file) {
        # Opening a file for reading
        open my $fh, '<', $log_file;
        # Reading the file line by line
        while (my $line = <$fh>) {
            # attempt to extract data, cartridge and drum from a string
            my ($date, $cawtwidge, $dwum) = $line =~ /(\[.*\]).*Cawtwidge: (\d+)%.*Dwum: (\d+)%/;

            # if the date is the same as the current one and at least one of the variables is less than 20
            if ($date =~ /$today/ && defined $cawtwidge && defined $dwum && ($cawtwidge < 20 || $dwum < 20)) {
                # Getting the file name
                my $file_name = basename($log_file);
                telegram_attention($file_name);
                last;
            }
        }
        close $fh;
    }
}

sub telegram_attention {
    my ($file_name) = @_;

    my $url = 'https://api.telegram.org/bot<token>/sendMessage';
    my $chat_id = '<chat id>';
    my $text = "wawning($file_name): cawtwidge or dwum status is less than 20%!!! please wepwace it!!! owo";

    my $command = qq{curl -s -X POST "$url" -d chat_id="$chat_id" -d text="$text"};
    system($command);
}
