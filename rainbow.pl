#!/usr/bin/perl
# This script applies a rainbow (altering the hue) to a herbstluftwm color property
# Requires Graphics::ColorUtils from CPAN

# Configuration
my $property = 'window_border_active_color'; # the color property to change
my $fps = 5; # changes per second
my $step = 1; # steps per change (hue values lie in the range 0-360)
my $track = 1; # set to 1 to track external property changes (more expensive)

use Graphics::ColorUtils;
use Time::HiRes qw(usleep);

my $delay = 1000000 / $fps;
my $first = 1;
while (true) {
	usleep($delay);
	my $hex, $h, $s, $v;
	if ($first) {
		$hex = substr(`herbstclient get $property`, 1, -1);
		($h, $s, $v) = rgb2hsv(unpack 'C*', pack 'H*', $hex);
		$h = int($h + 0.99); # ceil to prevent getting stuck
		$first = $track; # only redo this when tracking is on
	}

	$h = ($h + $step) % 360;
	$hex = hsv2rgb($h, $s, $v);
	system("herbstclient", "set", "$property", "$hex");
}
