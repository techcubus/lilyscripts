#!/usr/bin/perl -w
# uv5r2json.pl - A magic perl script by Lily <djlilis@yahoo.com>
# For use with Baofeng UV5R class radios only.
# This started as an idea from a blind close friend, turned into a expirement
# for ChatGPT, and is being re-written into working by me. The first priority
# of this script will be to assist blind people in managing UV5R radio dumps.
# TODO:
# Arguments (pretty, debug, channels, parameter blocks)
# json2uv5r
#


use strict;          # yolo
use warnings;        # et tu, lwall?
use JSON;            # manipulate json for i/o
use Data::Dumper;    # printing variables during debug

my $backup_file;
my $fh;
my $header;
my $num_channels = 128;
my @channels;
my $data;
my $makeup = "";
my $debug  = "";

# For now, just one file.
$backup_file = $ARGV[0];
open $fh, '<:raw', $backup_file or die "Can't open $backup_file: $!";

# This header is not right. we need to skip forward 8 bytes
# Plus ignore the magic - the meaning of the bits is todo
# Read the header (and ignore it for now)
read($fh, $header, 8);

# Header decode (and sanity check) goes here
# die "Invalid file format" unless $header eq "BFBX";

# Number of channels is fixed. We need verification that the file
# is the expected format in here in the future. We also need
# argument parsing
$num_channels = 64;

# This has been pretty much rewritten in structure from the GenAI by now

# Read channel frequencies first
for ( my $i = 0; $i < $num_channels; $i++ ) {
    # Read the channel data
    # Data size needed fixing
    read( $fh, $data, 8 );

    # Add channel index and unpack the frequency data into a hash
    my %channel;
    $channel{'index'} = $i;
    if ( $debug ) {print(sprintf ( "FChunk($i): %4X\n", unpack( "L", $data )))};
    if ( $debug ) {print( Dumper( $data ) )};
    $channel{'freq'} = sprintf( "%4X", unpack("L", substr($data, 0, 4)));

    # Get channel attributes. These will be discovered eventually
    read( $fh, $data, 8 );
    if ( $debug ) {print(sprintf ( "AChunk($i): %4X\n", unpack( "L", $data )))};
    if ( $debug ) {print( Dumper( $data ) )};
    $channel{'attribs'} = sprintf( "%4X", unpack("L", substr($data, 0, 4)));

    # Stick the channel in an array and loop
    push @channels, \%channel;
}

# Original structure for my reference
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

# Close our file handle like a good girl
close $fh;

# Create the JSON object with libjson-perl
my $json = JSON->new->allow_nonref;

# If we want pretty printing turn it on
if ( $makeup ) {$json = $json->pretty([$makeup])};

# Encode the array to JSON
$json = $json->encode([@channels]);

# Finally, print
print "$json\n";
