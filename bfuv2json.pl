use strict;
use warnings;
use JSON;

my $backup_file = 'path/to/backup/file.bfb';

open my $fh, '<:raw', $backup_file or die "Can't open $backup_file: $!";

# Read the header
my $header;
read($fh, $header, 4);

# Check the file type
die "Invalid file format" unless $header eq "BFBX";

# Read the number of channels
my $num_channels;
read($fh, $num_channels, 2);
$num_channels = unpack("v", $num_channels);

my @channels;
for (my $i = 0; $i < $num_channels; $i++) {
    # Read the channel data
    my $data;
    read($fh, $data, 64);

    # Unpack the data into a hash
    my %channel = (
        name => unpack("Z16", substr($data, 0, 16)),
        freq => unpack("V", substr($data, 16, 4)) / 1000000,
        ctcss_dcs => unpack("v", substr($data, 20, 2)),
        mode => unpack("C", substr($data, 22, 1)),
        dtmf => unpack("v", substr($data, 23, 2)),
        tx_power => unpack("C", substr($data, 25, 1)),
        scan => unpack("C", substr($data, 26, 1)),
        step => unpack("C", substr($data, 27, 1)),
        alt_freq => unpack("V", substr($data, 28, 4)) / 1000000,
        offset_dir => unpack("C", substr($data, 32, 1)),
        offset_freq => unpack("v", substr($data, 33, 2)) / 1000000,
        tone_burst => unpack("C", substr($data, 35, 1)),
        tone_burst_freq => unpack("V", substr($data, 36, 4)) / 1000000,
        comment => unpack("Z20", substr($data, 40, 20)),
    );

    push @channels, \%channel;
}

close $fh;

my $json = encode_json(\@channels);
print $json;
