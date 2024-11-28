#!/usr/bin/env perl
use strict;
use warnings;
use Net::SNMP;
use Log::Any qw($log);
use Log::Any::Adapter ('File', '/var/log/uwuscan/XeroxWorkCentre3225.log');
use lib "/etc/uwuscan/parameters/Xerox";
use XeroxWorkCentre3225;

my $community = 'public';

foreach my $element (@set::ip_address) {
    my ($session, $error) = Net::SNMP->session(
        Hostname  => $element,
        Community => $community,
        Version   => 2
    );

    if (!defined($session)) {
        # Connection error handling
        $log->info("Failed to connect to the device $element: $error");
    }

    # Getting the values of the tuner and the drum cartridge
    my $cartridge_max_status     = $session->get_request(-varbindlist => [ $set::oid_list[0] ]);
    my $cartridge_current_status = $session->get_request(-varbindlist => [ $set::oid_list[1] ]);

    # Check if the values are defined and calculate the state as a percentage
    if (   defined($cartridge_max_status->{$set::oid_list[0]})
        && defined($cartridge_current_status->{$set::oid_list[1]})
    ) {
        my $status_cartridge = ($cartridge_max_status->{$set::oid_list[0]} - $cartridge_current_status->{$set::oid_list[1]}) / $cartridge_max_status->{$set::oid_list[0]} * 100;
        my $cartridge        = 100 - $status_cartridge;

        # Log
        $log->info("$element - Cawtwidge: $cartridge%");
    }
}
