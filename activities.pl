#!/usr/bin/perl
use v5.20;

my %actof = (); # mapping tag -> activity
my %tagof = (); # mapping activity -> used tag
my $current_activity = -1;
my $current_tag = -1;
my %index = (); # for each activity, an array of tags
my %actcolor = (); # a distinguishing color string for each activity

sub build_index
{
	my $last = `herbstclient attr tags.count` - 1;
	for (0..$last) {
		my $tag = `herbstclient attr tags.$_.name`;
		chomp $tag;
		push @{$index{$actof{$tag}}}, $tag;
	}
}

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

sub tag_removed
{
	my ($in, $tag, $mergetag) = @_;
	foreach (keys %tagof) {
		if ($tagof{$_} eq $tag) {
			$tagof{$_} = $mergetag;
			print "current tag of activity $_ is now $tagof{$_}\n";
		}
	}
	delete $actof{$tag};
	print "removed $tag\n";
	#invalidate index
	%index = ();
}

sub tag_renamed
{
#my ($in, $tag) = @_;
#delete $actof{ $tag };
	print "TODO: tag rename hook broken in hlwm!\n";
	#invalidate index
	%index = ();
}

sub tag_selected
{
	my ($in, $tag, $monitor) = @_;
	$current_tag = $tag;
	if ($actof{$tag} ne $current_activity) {
		$current_activity = $actof{$tag};
		print "implicitely switched to activity $current_activity\n";
		system("herbstclient", "set", "window_border_active_color",
			"$actcolor{$current_activity}");
	}
	$tagof{$current_activity} = $tag;
	print "current tag of activity $current_activity is now $tag\n";
}

sub tag_cycle
{
	my ($in, $command) = @_;
	if (!%index) {
		build_index();
	}
	my @arr = @{$index{$current_activity}};
	my ($idx) = grep { $arr[$_] eq $current_tag } 0..$#arr;
	$idx += 1 if ($command eq 'next');
	$idx -= 1 if ($command eq 'prev');
	$idx = $#arr if ($idx < 0);
	$idx = 0 if ($idx > $#arr);
	print "$idx in $#arr, use $arr[$idx]\n";
	system("herbstclient", "use", $arr[$idx]);
}

sub activity_selected
{
	my ($in, $activity) = @_;
	if ($activity ne $current_activity) {
		$current_activity = $activity;
		if ($tagof{$current_activity} ne -1) {
			system("herbstclient", "use", $tagof{$current_activity});
		}
		print "changed activity to $current_activity, '$actcolor{$current_activity}'\n";
		system("herbstclient", "set", "window_border_active_color",
			"$actcolor{$current_activity}");
	}
}

sub activity_added
{
	my ($in, $activity, $color) = @_;
	$tagof{$activity} = -1;
	$actcolor{$activity} = $color;
#	if ($current_activity == -1) {
#		$current_activity = $activity;
#	}
	print "added activity $activity with color $actcolor{$activity}\n";
}

open HOOKS, "herbstclient -i |"
	or die "can't fork: $!";
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
	}
}
close HOOKS or die "unfinished love story: $! $?";
