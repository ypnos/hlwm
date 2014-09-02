#!/usr/bin/perl
use strict;

# ACTIVITIES AND TAGS
my @activities = qw( main devel write admin ); # defines the order
my %act_tags = (
	main => [ 'browse', 'mail', 'main_trois' ],
	devel => [ 'ide', 'foo', 'bar' ],
	write => [ 'tex', 'write_deux', 'write_trois' ],
	admin => [ 'admin_un', 'root', 'admin_trois' ]
);
my %act_keys = (main => 1, devel => 2, write => 3, admin => 4);

# KEYBINDINGS
my $Mod = "Mod4"; # win
my $Alt = "Mod1"; # alt key
my $Ctrlalt = "Mod1-Control"; # ctrl+alt
my $RESIZESTEP = 0.05;
my $RESIZESTEPA = 0.01;

my %bindings = (
	# general commands
	"$Mod-Control-q" => "close",
	"$Mod-Control-r" => "reload",
	"$Mod-Control-Delete" => "quit",
	"$Mod-Return" => "spawn qterminal",
	"$Mod-l" => "spawn xscreensaver-command -lock",	#XF86PowerOff

	# cycle through tags
	"$Ctrlalt-Right" => "emit_hook activity_tag next",
	"$Ctrlalt-Left" => "emit_hook activity_tag prev",

	"$Ctrlalt-m" => "use mail",
	"$Ctrlalt-b"  => "use browse",
	"$Ctrlalt-a"  => "use root",

	# move windows through tags
	"$Ctrlalt-period" => "move_index +1 --skip-visible",
	"$Ctrlalt-comma"  => "move_index -1 --skip-visible",

	# layouting
	"$Mod-r" => "remove",
	"$Mod-space" => "cycle_layout 1",
	"Mod-Control-space" => "split explode",

	"$Mod-u" => "split vertical 0.5",
	"$Mod-o" => "split horizontal 0.5",
	"$Mod-g" => "floating toggle",
	"$Mod-f" => "fullscreen toggle",
	"$Mod-p" => "pseudotile toggle",

	# resizing
	"$Mod-Shift-Up" => "resize up +$RESIZESTEP",
	"$Mod-Shift-Left" => "resize left +$RESIZESTEP",
	"$Mod-Shift-Down" => "resize down +$RESIZESTEP",
	"$Mod-Shift-Right" => "resize right +$RESIZESTEP",
	"$Mod-Control-Shift-Up" => "resize up +$RESIZESTEPA",
	"$Mod-Control-Shift-Left" => "resize left +$RESIZESTEPA",
	"$Mod-Control-Shift-Down" => "resize down +$RESIZESTEPA",
	"$Mod-Control-Shift-Right" => "resize right +$RESIZESTEPA",

	# focus
	"$Mod-Tab" => "cycle +1",
	"$Alt-Tab" => "cycle_all +1",
	"$Mod-Shift-Tab" => "cycle -1",
	"$Mod-c" => "cycle",
	"$Mod-Up" => "focus up",
	"$Mod-Left" => "focus left",
	"$Mod-Down" => "focus down",
	"$Mod-Right" => "focus right",
	"$Mod-i" => "jumpto urgent",
	"$Mod-Control-Up" => "shift up",
	"$Mod-Control-Left" => "shift left",
	"$Mod-Control-Down" => "shift down",
	"$Mod-Control-Right" => "shift right"
);

my %mbindings = (
	"$Mod-Button1" => "move",
	"$Mod-Button2" => "zoom",
	"$Mod-Button3" => "resize",
#	"$Mod-Button4" => "call use_index +1",
#	"$Mod-Button5" => "call use_index -1"
);

my %settings = (
	# behavior
	focus_follows_mouse => 1,
	mouse_recenter_gap => 0,

	# colors
	frame_border_active_color => '#000000',
	frame_border_normal_color => '#123456',
	frame_bg_normal_color => '#000000',
	frame_bg_active_color => '#000000',
	window_border_normal_color => '#000000',
	window_border_active_color => '#dd0000',

	# borders
	always_show_frame => 1,
	frame_border_width => 0,
	window_border_width => 3,
	window_border_inner_width => 1,
	frame_gap => 0,
	window_gap => 3,
	frame_padding => -2,
	smart_window_surroundings => 0,
	smart_frame_surroundings => 1,

	# w0rd
	tree_style => '╾│ ├└╼─┐'
);

# ROUTINES

sub ext {
	system("@_");
}

sub hc {
    system("herbstclient @_");
}

sub keybinds(\%) {
	my $ref = shift;
	my $output;
	while (my ($key, $value) = each(%$ref)) {
		$output .= " ßß keybind $key $value";
	}
	hc("chain $output");
}

sub mousebinds(\%) {
	my $ref = shift;
	my $output;
	while (my ($key, $value) = each(%$ref)) {
		$output .= " ßß mousebind $key $value";
	}
	hc("chain $output");
}

sub settings(\%) {
	my $ref = shift;
	my $output;
	while (my ($key, $value) = each(%$ref)) {
		$output .= " ßß set $key $value";
	}
	hc("chain $output");
}

sub flush {
	hc "emit_hook reload";

	# set background
	ext("xsetroot -solid '#000000'");

	# start activities script (in screen for later debugging)
	ext("screen -S activities -d -m ~/.config/herbstluftwm/activities.pl");
	# start redecoration script
	ext("~/.config/herbstluftwm/redecorate.pl&");

	# unset bindings, rules
	hc "keyunbind --all";
	hc "mouseunbind --all";
	hc "unrule -F";
}


# MAIN

flush();

hc qq(rename default "$act_tags{$activities[0]}[0]");
for my $act (@activities) {
    hc qq(emit_hook activity_create "$act");
    hc qq(emit_hook activity_switch "$act");
	for my $tag (@{$act_tags{$act}}) {
		hc qq(add "$tag");
	}
	my $key = $act_keys{$act};
	if (!! "$key") {
        hc qq(keybind $Mod-$key emit_hook activity_switch "$act");
    }
}
hc qq(emit_hook activity_switch "$activities[0]");

# set bindings, settings as defined above
keybinds(%bindings);
mousebinds(%mbindings);
settings(%settings);

# set rules
hc "rule focus=on"; # normally do focus new clients

hc qq(rule "windowtype~_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)" pseudotile=on);
hc qq(rule "windowtype=_NET_WM_WINDOW_TYPE_DIALOG'" focus=on);
hc qq(rule "windowtype~_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)" manage=off);

# remove panel space from below
hc "pad 0 0 0 32 0";

# unlock, just to be sure
hc "unlock";

# start compton
#ext("compton -b --config ~/.config/compton.conf");
