#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

my $directory = '/var/uwuscan_log';
my $warning_sent = 0;

my @files = glob("$directory/*.log");

foreach my $filename (@files) {
  if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
    while (my $row = <$fh>) {
      chomp $row;
      my @fields = split(' ', $row);
      my $cartridge = $fields[6];
      my $drum = $fields[7];

      if ($cartridge < 20 || $drum < 20) {
        if(!$warning_sent){
          & telegram_attention;
          $warning_sent =1;  
        }

        last;
        
      }
    }
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
