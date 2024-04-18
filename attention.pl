#!/usr/bin/env perl

use strict;
use warnings;

my $dir = '/var/uwuscan_log';
my $num = 0;

for my $log_file (grep{-f}<$dir/*>) {
    open (my $fh, '<', $log_file);
    my @file = <$fh>;
    close $fh;

    while (1) {
        my $line = @file - 1 - $num;
        my ($cawtwidge, $dwum) = $file[$line] =~ /Cawtwidge: (\d+)%.*Dwum: (\d+)%/;

        if (!defined $cawtwidge || !defined $dwum) {
            last;
        }

        if ($cawtwidge < 20 || $dwum < 20) {
            telegram_attention();
            last;
        }

        ++$num;
        last;
    }
}

sub telegram_attention {
    my $url = 'https://api.telegram.org/bot<token>/sendMessage';
    my $chat_id = '<chat id>';
    my $text = 'wawning: cawtwidge or dwum status is less than 20%!!! please wepwace it!!! owo';

    my $command = qq{curl -s -X POST "$url" -d chat_id="$chat_id" -d text="$text"};
    system($command);
}
