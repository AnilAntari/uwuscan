use strict;
use warnings;
use 5.010;

my $directory = '/var/uwuscan_log';
my $warning_sent = 0;

opendir(my $dh, $directory);
my @files = readdir($dh);

foreach my $filename (@files) {
    next unless ($filename =~ /\.log$/);
    $filename = "$directory/$filename";

    if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
        my @lines = reverse <$fh>;
        foreach my $row (@lines) {
            chomp $row;
            my @fields = split(' ', $row);
            my $cartridge = $fields[6];
            my $drum = $fields[7];

            if ($cartridge < 20) {
                if (!$warning_sent) {
                    telegram_attention();
                    $warning_sent = 1;
                }

            } elsif ($drum < 20) {
                    if (!$warning_sent) {
                        telegram_attention();
                        $warning_sent = 1;
                    }
                }
        }

        close $fh;
    }
}

sub telegram_attention {
    my $url = 'https://api.telegram.org/bot<bot_api>/sendMessage';
    my $chat_id = '<chat id>';
    my $text = 'wawning: cawtwidge or dwum status is less than 20%!!! please wepwace it!!! owo';

    $chat_id =~ s/"/\\"/g;
    $text =~ s/"/\\"/g;

    my $command = qq{curl -s -X POST "$url" -d chat_id=$chat_id -d text=$text};
    system($command);
}
