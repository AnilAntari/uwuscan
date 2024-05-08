#!/usr/bin/env perl

use strict;
use warnings;

my $dir = '/var/uwuscan_log';
my $num = 0;

FILE: for my $log_file (glob "$dir/*") {
    # проверяем, что файл существует и является файлом
    if (-f $log_file) {
        # открываем файл на чтение
        open my $fh, '<', $log_file;
        # читаем файл построчно
        while (my $line = <$fh>) {
            # если строка содержит "Cawtwidge: % и Dwum: %"
            my ($cawtwidge, $dwum) = $line =~ /Cawtwidge: (\d+)%.*Dwum: (\d+)%/;
            # если переменные определены и хотя бы одна из них меньше 20
            if (defined $cawtwidge && defined $dwum && ($cawtwidge < 20 || $dwum < 20)) {
                # отправляем сообщение в телеграм
                telegram_attention();
                last FILE;
            }
        }
        close $fh;
    }
}


sub telegram_attention {
    my $url = 'https://api.telegram.org/bot<token>/sendMessage';
    my $chat_id = '<chat id>';
    my $text = 'wawning: cawtwidge or dwum status is less than 20%!!! please wepwace it!!! owo';

    my $command = qq{curl -s -X POST "$url" -d chat_id="$chat_id" -d text="$text"};
    system($command);
}
