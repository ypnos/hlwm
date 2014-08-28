#!/bin/bash

hc() {
    herbstclient "$@"
}

hc emit_hook reload

xsetroot -solid '#000000'

# start activities script (in screen for later debugging)
screen -S activities -d -m ~/.config/herbstluftwm/activities.pl
# start redecoration script
~/.config/herbstluftwm/redecorate.pl &

# remove all existing keybindings
hc keyunbind --all

# keybindings
Mod=Mod4 # win
Alt=Mod1 # alt key
Ctrlalt=Mod1-Control # ctrl+alt
hc keybind $Mod-Control-q close
hc keybind $Mod-Control-r reload
hc keybind $Mod-Control-Delete quit
hc keybind $Mod-Return spawn qterminal
#hc keybind XF86PowerOff spawn xlock
hc keybind $Mod-l spawn xscreensaver-command -lock

# activities and tags
ACT_NAMES=( main devel write admin )
ACT_KEYS=( {1..4} )
TAG_NAMES=( un deux trois )

hc rename default "${ACT_NAMES[0]}_${TAG_NAMES[0]}" || true
for j in ${!ACT_NAMES[@]} ; do
	act=${ACT_NAMES[$j]}
	hc emit_hook activity_create "$act"
	hc emit_hook activity_switch "$act"
	for i in ${!TAG_NAMES[@]} ; do
	    hc add "${act}_${TAG_NAMES[$i]}"
	#    key="${TAG_KEYS[$i]}"
	#    if ! [ -z "$key" ] ; then
	#        hc keybind "$Mod-$key" use_index "$i"
	#        hc keybind "$Mod-Shift-$key" move_index "$i"
	#    fi
	done
	key="${ACT_KEYS[$j]}"
	if ! [ -z "$key" ] ; then
		hc keybind "$Mod-$key" emit_hook activity_switch "$act"
	fi
done
hc emit_hook activity_switch ${ACT_NAMES[0]}

# cycle through tags
#hc keybind $Ctrlalt-Right use_index +1 --skip-visible
#hc keybind $Ctrlalt-Left  use_index -1 --skip-visible
hc keybind $Ctrlalt-Right emit_hook activity_tag next
hc keybind $Ctrlalt-Left emit_hook activity_tag prev

# move windows through tags
hc keybind $Ctrlalt-period move_index +1 --skip-visible
hc keybind $Ctrlalt-comma  move_index -1 --skip-visible

# layouting
hc keybind $Mod-r remove
hc keybind $Mod-space cycle_layout 1
hc keybind $Mod-Control-space split explode

hc keybind $Mod-u split vertical 0.5
hc keybind $Mod-o split horizontal 0.5
hc keybind $Mod-g floating toggle
hc keybind $Mod-f fullscreen toggle
hc keybind $Mod-p pseudotile toggle

# resizing
RESIZESTEP=0.05
RESIZESTEPA=0.01
hc keybind $Mod-Shift-Up resize up +$RESIZESTEP
hc keybind $Mod-Shift-Left resize left +$RESIZESTEP
hc keybind $Mod-Shift-Down resize down +$RESIZESTEP
hc keybind $Mod-Shift-Right resize right +$RESIZESTEP
hc keybind $Mod-Control-Shift-Up resize up +$RESIZESTEPA
hc keybind $Mod-Control-Shift-Left resize left +$RESIZESTEPA
hc keybind $Mod-Control-Shift-Down resize down +$RESIZESTEPA
hc keybind $Mod-Control-Shift-Right resize right +$RESIZESTEPA

# mouse
hc mouseunbind --all
hc mousebind $Mod-Button1 move
hc mousebind $Mod-Button2 resize
hc mousebind $Mod-Button3 zoom
hc mousebind $Mod-Button4 call use_index +1
hc mousebind $Mod-Button5 call use_index +1

# focus
hc set focus_follows_mouse 1
hc set focus_follows_shift 1

hc keybind $Mod-BackSpace   cycle_monitor
hc keybind $Mod-Tab         cycle_all +1
hc keybind $Alt-Tab         cycle_all +1
hc keybind $Mod-Shift-Tab   cycle_all -1
hc keybind $Mod-c cycle
hc keybind $Mod-Up focus up
hc keybind $Mod-Left focus left
hc keybind $Mod-Down focus down
hc keybind $Mod-Right focus right
hc keybind $Mod-i jumpto urgent
hc keybind $Mod-Control-Up shift up
hc keybind $Mod-Control-Left shift left
hc keybind $Mod-Control-Down shift down
hc keybind $Mod-Control-Right shift right

# colors
hc set frame_border_active_color '#000000'
hc set frame_border_normal_color '#000000'
hc set frame_bg_normal_color '#000000'
hc set frame_bg_active_color '#000000'
hc set frame_border_width 0
hc set window_border_width 3
hc set window_border_inner_width 1
hc set window_border_normal_color '#000000'
hc set window_border_active_color '#dd0000'
hc set always_show_frame 1
hc set frame_gap 0
# add overlapping window borders
hc set window_gap 3
hc set frame_padding -2
hc set smart_window_surroundings 0
hc set smart_frame_surroundings 1
hc set mouse_recenter_gap 0


# rules
hc unrule -F
#hc rule class=XTerm tag=3 # move all xterms to tag 3
hc rule focus=on # normally do focus new clients
# give focus to most common terminals
hc rule class~'(.*[Rr]xvt.*|.*[Tt]erm|Konsole)' focus=on
hc rule windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' pseudotile=on
hc rule windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on
hc rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off

# let it be an overlay
#hc rule title='LXQt Runner' manage=off focus=on

# unlock, just to be sure
hc unlock

hc set tree_style '╾│ ├└╼─┐'

# do multi monitor setup here, e.g.:
# hc set_monitors 1280x1024+0+0 1280x1024+1280+0
# or simply:
# hc detect_monitors
#herbstclient move_monitor 0 1920x1168+0+0 # remove panel space from below
hc pad 0 0 0 32 0 # remove panel space from below

# find the panel
#panel=~/.config/herbstluftwm/panel.sh
#[ -x "$panel" ] || panel=/etc/xdg/herbstluftwm/panel.sh
#for monitor in $(herbstclient list_monitors | cut -d: -f1) ; do
    # start it on each monitor
#    "$panel" $monitor &
#done

# start compton
#compton -b --config /home/jordan/.config/compton.conf
