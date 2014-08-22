hlwm
====

My config and scripts for herbstluftwm. Right now consists of activities.pl and the corresponding section in autostart (and my pretty random personal preferences).

Activities
=========

This script enhances the virtual desktop with a concept similar to the Activities in KDE (from a window manager point-of-view). You can think of activities as tag groups. Each tag is associated to an activity. When switching activity, the tag that was last used within that activity is automatically selected. You can also cycle through the tags of an activity (not leaving the activity).

Why Activities
---------------

Activities are most valuable if you have long uptimes and work on several projects at the same time. For example, as a researcher, you can have one activity for preparing publications, another one for writing code, another one for experiments. In the publication activity, you use one tag for writing your article (editor, PDF viewer, terminal), another tag for inkscape and gimp (using the gimp tag layout), to work on figures, a third tag for literature review (browser, PDF viewers, citation manager). It is one big work project but you wouldn't want to cram one tag/workspace with all of it.

Concept
---------

You can add a new activity, which has a name, and a color, anytime. When you add a tag, it is automatically assigned to the current activity. You can assign shortcuts to switch to each activity (by emiting a hook). Activities keep track on which tag you left off, so switching to a different activity and back is a seamless process.

You can still directly access any tag. If you access a tag in activity X directly coming from activity Y, the system will notice that you are now in activity X and remember that you visited this tag in activity X last. In most cases, though, you might want to cycle through the tags within a specific activity. Right now you can cycle left and right based on the internal index of each tag (tag indices are assigned by herstbluftwm and depend on the creation time). A good number of tags per activity is three: In any tag you can reach each other tag by going either left or right. However, the system supports any number of tags for each activity. This is different than the KDE system, where the number of workspaces is the same for all activities.

To discern activities, the activity's color is used as the focused window border color. This is hardcoded and should be more flexible in the future. However activities.pl is a small script and easy to alter.

Usage
-------

Include activities.pl at the very beginning after each reload:
`~/.config/herbstluftwm/activities.pl &`

To be able to read debug output during the session you can run it like this:
`screen -S activities -d -m ~/.config/herbstluftwm/activities.pl`

Use herstbclient (directly or via key binding) to issue commands:

`emit_hook activity_added _name_ _color code_` add an activity
`emit_hook activity_changed _name_` switch to activity
`emit_hook activity_removed _name_` TODO: not implemented yet!
`emit_hook activity_tag _next|prev_` cycle to right/left tag within activity

Newly created tags are always added to the current activity. It is not possible yet to move tags between activities (TODO).


Known Issues
---------------

1. Right now we do not account for monitors.
2. When merging a tag A of activity X with a tag of different activity Y, while A is the current tag of X, X will lose its current tag. To get back to X, you need to directly jump to another tag in X.
3. Renaming tags is not supported as the hook does not tell us _which_ tag was renamed.
4. Removing activities is not implemented. You can however remove all tags of an activity and then forget about it.


Missing functionality
-----------------------

While this is already pretty decent for my personal needs, these are the next logical steps when enhancing the script, apart from fixing the issues listed above:

1. Enhance `activity_tag` hook to support the same indexing parameters as `use_index`
2. Instead of decorating with a color, allow custom commands to be issued when entering and leaving an activity
3. Add functionality to move tags between activities

All three of these are rather easy to implement. Patches are welcome!
