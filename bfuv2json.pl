#!/usr/bin/perl -w

use strict;
use warnings;
use JSON;

my $backup_file;
my $fh;
my $header;
my $num_channels;
my @channels;
my $data;

# my $backup_file = 'path/to/backup/file.bfb';
# ChatGPT showed us a static example. Will add multiple file handling.
# For now, just one file.
$backup_file = $ARGV[0];
open $fh, '<:raw', $backup_file or die "Can't open $backup_file: $!";

# This goes off the rails quickly
# Read the header
read($fh, $header, 8);

# Check the file type
# die "Invalid file format" unless $header eq "BFBX";

# This header is not right. we need to skip forward 8 bytes
# Plus ignore the magic - the meaning of the bits is todo

# Number of channels is fixed. We need verification that the file
# is the expected format in here in the future
$num_channels = 5;

# This is a bizarre mess not totally unexpected from GenAI...

for ( my $i = 0; $i < $num_channels; $i++ ) {
    # Read the channel data
    # Data size needed fixing
    read($fh, $data, 16);

    # Unpack the data into a hash
    # This is a mess, totally out of order but some of the correct fields
    # In reality, all we find at this point is frequency data in LE BCD
    my %channel;
    $channel{'index'} = $i;
    $channel{'freq'} = sprintf( "%4X", unpack("L", substr($data, 0, 4)));

#    $channel{'offset_freq'} = unpack("V", substr($data, 4, 4)) / 10000000;
#    my %channel = (
#        name => unpack("Z16", substr($data, 0, 16)),
#        freq => unpack("V", substr($data, 16, 4)) / 1000000,
#        ctcss_dcs => unpack("v", substr($data, 20, 2)),
#        mode => unpack("C", substr($data, 22, 1)),
#        dtmf => unpack("v", substr($data, 23, 2)),
#        tx_power => unpack("C", substr($data, 25, 1)),
#        scan => unpack("C", substr($data, 26, 1)),
#        step => unpack("C", substr($data, 27, 1)),
#        alt_freq => unpack("V", substr($data, 28, 4)) / 1000000,
#        offset_dir => unpack("C", substr($data, 32, 1)),
#        offset_freq => unpack("v", substr($data, 33, 2)) / 1000000,
#        tone_burst => unpack("C", substr($data, 35, 1)),
#        tone_burst_freq => unpack("V", substr($data, 36, 4)) / 1000000,
#        comment => unpack("Z20", substr($data, 40, 20)),
#    );

    push @channels, \%channel;
}

close $fh;

my $json = JSON->new->allow_nonref;
my $enable = "true";
$json = $json->pretty([$enable]);
$json = $json->encode([@channels]);

print $json;
