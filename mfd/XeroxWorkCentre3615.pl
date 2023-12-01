#!/usr/bin/perl
use strict;
use warnings;
use Net::SNMP;

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

    # Connection error Handling
    if (!defined($session)) {
        	die "Failed to connect to the device $element: $error";
    }

    # Getting the values of the tuner and the drum cartridge
    my @oid_list = (
    	'1.3.6.1.2.1.43.11.1.1.8.1.1', # Cartridge max status 
    	'1.3.6.1.2.1.43.11.1.1.9.1.1', # Cartridge current status  
    	'1.3.6.1.2.1.43.11.1.1.8.1.2', # Drum max status  
    	'1.3.6.1.2.1.43.11.1.1.9.1.2'  # Drum current status  
     );
	
    my $cartridge_max_status = $session->get_request(-varbindlist => [$oid_list[0]]);
	my $cartridge_current_status = $session->get_request(-varbindlist => [$oid_list[1]]);
    my $drum_max_status = $session->get_request(-varbindlist => [$oid_list[2]]);
    my $drum_current_status = $session->get_request(-varbindlist => [$oid_list[3]]);

    # РCalculating the state as a percentage
    my $status_cartridge = ($cartridge_max_status->{$oid_list[0]} - $cartridge_current_status->{$oid_list[1]}) / $cartridge_max_status->{$oid_list[0]} * 100;
    my $cartridge = 100 - $status_cartridge;
    my $drum_status = ($drum_max_status->{$oid_list[2]} - $drum_current_status->{$oid_list[3]}) / $drum_max_status->{$oid_list[2]} * 100;
    my $drum = 100 - $drum_status;


	my $time = localtime();
	my $heredoc =<<"END_MESSAGE";
$timeсв
Xerox WorkCentre 3615

IP-address: $element
Status cartridge: ${cartridge}%
Status drum: ${drum}%
---
END_MESSAGE
    # Writing current values to a log file
    my $log_file = '/var/uwuscan_log/XeroxWorkCentre3615_log.txt';
    open(my $log, '>>', $log_file) or die "Error";
	say $log $heredoc;
}
