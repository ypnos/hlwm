#!/usr/bin/perl
# This script watches for activity changes and gives visual feedback

## Configuration
my %colors = (
	main => '#DD0000',
	devel => '#13B8E0',
	write => '#96E013',
	admin => '#C713E0',
   	tests => '#E04613'
);

## Apply activity color
# Right now we change the active window's border color to the activity's color.
sub redecorate
{
	my ($foo, $activity) = @_;
	system("herbstclient", "set", "window_border_active_color",
		"$colors{$activity}");
}

## main routine
use v5.14;

# set up a pipe for reading hooks
open HOOKS, "herbstclient -i '(activity_changed|reload)'|"
	or die "can't fork: $!";
# process incoming messages
OUTER:
while (<HOOKS>) {
	chomp;
	for ($_) {
		redecorate(split(/\t/)) when /^activity_changed/;
		last OUTER when /^reload/; # quit on reload
	}
}
close HOOKS or die "unfinished love story: $! $?"; # happens on hlwm crash
