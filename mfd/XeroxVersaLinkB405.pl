#!/usr/bin/perl
use strict;
use warnings;
use Net::SNMP;
use Log::Any qw($log);
use Log::Any::Adapter ('File', '/var/uwuscan_log/XeroxVersaLinkB405.log');

# List of polled IP addresses
my @ip_address = (
    'IP address'
);
my $community = 'public';

foreach my $element (@ip_address) {
    # Sending SNMP requests
    my ($session, $error) = Net::SNMP->session(
        Hostname => $element,
        Community => $community,
        Version => 2
    );

    if (!defined($session)) {
        # Connection error Handling
        die "Failed to connect to the device $element: $error";
    }

    # Getting the values of the tuner and the drum cartridge
    require '/etc/uwuscan/oid_list/XeroxVersaLinkB405.pm';
    my $cartridge_max_status = $session->get_request(-varbindlist => [$set::oid_list[0]]);
    my $cartridge_current_status = $session->get_request(-varbindlist => [$set::oid_list[1]]);
    my $drum_max_status = $session->get_request(-varbindlist => [$set::oid_list[2]]);
    my $drum_current_status = $session->get_request(-varbindlist => [$set::oid_list[3]]);

    # РCalculating the state as a percentage
    my $status_cartridge = ($cartridge_max_status->{$set::oid_list[0]} - $cartridge_current_status->{$set::oid_list[1]}) / $cartridge_max_status->{$set::oid_list[0]} * 100;
    my $cartridge = 100 - $status_cartridge;
    my $drum_status = ($drum_max_status->{$set::oid_list[2]} - $drum_current_status->{$set::oid_list[3]}) / $drum_max_status->{$set::oid_list[2]} * 100;
    my $drum = 100 - $drum_status;

	  # Log 
    $log->info($element, $cartridge, $drum); 
}
