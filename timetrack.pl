#!/usr/bin/perl
# This script tracks usage of windows / tags / activities over time.
use v5.20;
use IO::Select;
use Time::HiRes qw(time); # time() delivers floating seconds
use POSIX qw(strftime);
use sigtrap qw/handler lastsupper normal-signals/;

my $activity = 0;
my $tag = 0;
my $title = 0;
my $lastevent = -1;

sub timestamp
{
	my ($ts, $msg) = @_;
	my $dt = strftime "%Y-%m-%d%t%T", localtime($ts);
	print("$dt\t$ts\t$msg\n") if $title;
}

sub commit
{
	if ($lastevent > (time - 0.25)) {
		#print "holding off -> ".time." vs $lastevent \n";
	} else {
		timestamp($lastevent, "$activity\t$tag\t$title");
	}
	$lastevent = time;
}

sub lastsupper
{
	commit() and exit;
}

sub update_activity
{
	commit();
	$activity = $_[1];
}

sub update_tag
{
	commit();
	$tag = $_[1];
}

sub update_title
{
	commit();
	$title = $_[2];
}

sub enter_void
{
	$lastevent = -1;
	timestamp("inactive");
}

sub leave_void
{
	$lastevent = -1;
	timestamp("$activity\t$tag\t$title");
}

## main routine

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
		#print "************************ $buffer\n";
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
