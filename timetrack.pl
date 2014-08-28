#!/usr/bin/perl
# This script tracks usage of windows / tags / activities over time.

use POSIX qw(strftime);

my ($logfile) = @ARGV;
die "Usage: timetrack.pl <name of logfile>\n" unless $logfile;

my $activity = "undefined";
my $tag = "undefined";
my $title = "undefined";

sub timestamp
{
	my $msg = $_[0];
	my $ts = time;
	my $dt = strftime "%Y-%m-%d%t%T", localtime;
	print("$dt\t$ts\t$msg\n");
}

sub update_activity
{
	$activity = $_[1];
}

sub update_tag
{
	$tag = $_[1];
}

sub update_title
{
	$title = $_[2];
	timestamp("$activity\t$tag\t$title");
}

sub enter_void
{
	timestamp("inactive");
}

sub leave_void
{
	timestamp("$activity\t$tag\t$title");
}

## main routine
use v5.20;
use IO::Select;

# set up pipes
open my $hhandle, "herbstclient -i '(activity_changed|tag_changed|focus_changed|reload)'|"
	or die "can't fork: $!";
open my $shandle, "xscreensaver-command -watch|" or die "can't fork: $!";
my $sel = IO::Select->new($hhandle, $shandle);

# process incoming messages
OUTER:
while(my @ready = $sel->can_read) {
	foreach my $fh (@ready) {
		my $buffer = readline($fh);
		chomp $buffer;
		print "************************ $buffer\n";
		for ($buffer) {
			update_activity(split(/\t/)) when /^activity_changed/;
			update_tag(split(/\t/)) when /^tag_changed/;
			update_title(split(/\t/)) when /^focus_changed/;
			enter_void() when /^(BLANK|LOCK)/;
			leave_void() when /^UNBLANK/;
			last OUTER when /reload/; # quit on reload
			default { print "spurious capture: $buffer\n"; }
		}
	}
}

close($hhandle) or die "unfinished love story: $! $?\n"; # happens on hlwm crash
close($shandle) or die "unfinished hate story: $! $?\n"; # happens?
