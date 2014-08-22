#!/usr/bin/perl
use v5.20;

my %actof = (); # mapping tag -> activity
my %tagof = (); # mapping activity -> last used tag
my $current_activity = -1;
my $current_tag = -1;
my %index = (); # for each activity, an array of tags ordered by their indices
my %actcolor = (); # a distinguishing color string for each activity

## Query hlwm object system to find all tags according to their index.
# When cycling through tags, the user expects them to be ordered by their native
# index (based on creation time, but changes when tags get deleted). The index is
# not exposed by hlwm's hooks and tracking index changes is infeasible. That's why
# we reconstruct the order explicitely as soon as we need it; we invalidate our own
# version of the indexing whenever a hook tells us that index changes are possible
sub build_index
{
	my $last = `herbstclient attr tags.count` - 1;
	for (0..$last) {
		my $tag = `herbstclient attr tags.$_.name`;
		chomp $tag;
		push @{$index{$actof{$tag}}}, $tag;
	}
}

## Give visual feedback of the activity selection
# Right now we change the active window's border color to the activity's color.
# TODO: This should not be hardcoded but rather do some configurable stuff.
sub redecorate
{
	system("herbstclient", "set", "window_border_active_color",
		"$actcolor{$current_activity}");
}

## Handle tag addition
# Assign the new tag to the current activity. Invalidate tag index.
# In case the activity was empty, the tag becomes the activity's current tag.
sub tag_added
{
	my ($in, $tag) = @_;
	$actof{$tag} = $current_activity;
	print "activity of $tag is now $current_activity\n";
	if ($tagof{$current_activity} == -1) {
		$tagof{$current_activity} = $tag;
		print "implicitely set current tag of $current_activity to $tag\n";
	}
	#invalidate index
	%index = ();
}

## Handle tag removal
# When a tag is removed, it is merged with another one. If the other tag belongs to
# the same activity, we can reset the current tag (if needed). Otherwise we are
# stuck with a very unpleasant situation (TODO FIXME)
sub tag_removed
{
	my ($in, $tag, $mergetag) = @_;
	my $activity = $actof{$tag};
	if ($tagof{$activity} eq $tag) { # oups.. we delete the current tag!
		if ($actof{$mergetag} eq $activity) {
			$tagof{$activity} = $mergetag;
			print "current tag of activity $_ is now $tagof{$_}\n";
		} else {
			$tagof{$activity} = -1; # TODO: might make the activity unreachable
		}
	}
	delete $actof{$tag};
	print "removed $tag\n";
	#invalidate index
	%index = ();
}

## Keep track of tag renaming
# TODO: hlwm does not tell us *which* tag was renamed. We wait for a fix.
sub tag_renamed
{
	#my ($in, $tag) = @_;
	#delete $actof{ $tag };
	print "TODO: tag rename hook broken in hlwm!\n";
	#invalidate index
	%index = ();
}

## Keep track of current tag
# We might need to implicitely change the activity.
sub tag_selected
{
	my ($in, $tag, $monitor) = @_;
	$current_tag = $tag; # helpful for tag cycling
	if ($actof{$tag} ne $current_activity) {
		$current_activity = $actof{$tag};
		print "implicitely switched to activity $current_activity\n";
		redecorate();
	}
	$tagof{$current_activity} = $tag;
	print "current tag of activity $current_activity is now $tag\n";
}

## Cycle through tags within an activity
# Instead of the internal tag changing with +1/-1, we provide a rudimentary
# wrapper that keeps tab switching within the current activity.
# TODO: provide more options than just next/prev. E.g. absolute indices.
sub tag_cycle
{
	my ($in, $command) = @_;
	if (!%index) {
		build_index();
	}
	my @arr = @{$index{$current_activity}};
	# find position of current tag in the array of activity's tags
	my ($idx) = grep { $arr[$_] eq $current_tag } 0..$#arr;
	$idx += 1 if ($command eq 'next');
	$idx -= 1 if ($command eq 'prev');
	$idx = $#arr if ($idx < 0); # wrap around
	$idx = 0 if ($idx > $#arr); # wrap around
	print "switching to tag $arr[$idx] ($idx in 0..$#arr)\n";
	system("herbstclient", "use", $arr[$idx]);
}

## Activate an activity (nifty)
# Send hlwm to the acitivity's current tag and also redecorate.
sub activity_selected
{
	my ($in, $activity) = @_;
	if ($activity ne $current_activity) {
		$current_activity = $activity;
		# move to a tag within the activity if possible
		if ($tagof{$current_activity} ne -1) {
			system("herbstclient", "use", $tagof{$current_activity});
		}
		# If not possible, we still internally handle this as the current activity.
		# Newly created tags will be assigned to the current (this) activity!
		print "changed activity to $current_activity, '$actcolor{$current_activity}'\n";
		redecorate(); #slightly inconsistent
	}
}

## Add new activity
# Simple initialization only.
sub activity_added
{
	my ($in, $activity, $color) = @_;
	$tagof{$activity} = -1;
	$actcolor{$activity} = $color;
	print "added activity $activity with color $actcolor{$activity}\n";
}

## Remove activity
# Poor tags, where do they go?
sub activity_removed
{
	# TODO: an exercise for the reader!
}

## main routine

# set up a pipe for reading hooks
open HOOKS, "herbstclient -i |"
	or die "can't fork: $!";
# process incoming messages
OUTER:
while (<HOOKS>) {
	chomp;
	#print " # $_\n";
	for ($_) {
		tag_selected(split(/\t/)) when /tag_changed/;
		tag_added(split(/\t/)) when /tag_added/;
		tag_removed(split(/\t/)) when /tag_removed/;
		tag_renamed(split(/\t/)) when /tag_renamed/;
		tag_cycle(split(/\t/)) when /activity_tag/;
		activity_selected(split(/\t/)) when /activity_changed/;
		activity_added(split(/\t/)) when /activity_added/;
		activity_removed(split(/\t/)) when /activity_removed/;
		last OUTER when /reload/; # quit on reload
	}
}
close HOOKS or die "unfinished love story: $! $?"; # happens on hlwm crash
