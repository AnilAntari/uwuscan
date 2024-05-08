#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use POSIX qw(strftime);
use File::Basename;

my $dir = '/var/uwuscan_log';
my $today = strftime "%a %b %e", localtime; # получаем текущую дату в формате "Tue May 7"

for my $log_file (glob "$dir/*") {
    # проверяем, что файл существует и является файлом
    if (-f $log_file) {
        # открываем файл на чтение
        open my $fh, '<', $log_file;
        # читаем файл построчно
        while (my $line = <$fh>) {
            # пытаемся извлечь дату, cawtwidge и dwum из строки
            my ($date, $cawtwidge, $dwum) = $line =~ /(\[.*\]).*Cawtwidge: (\d+)%.*Dwum: (\d+)%/;

            # если дата совпадает с текущей и хотя бы одна из переменных меньше 20
            if ($date =~ /$today/ && defined $cawtwidge && defined $dwum && ($cawtwidge < 20 || $dwum < 20)) {
                # получаем имя файла
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
