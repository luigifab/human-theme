# set classic mode for font rendering (default in 2.6)
export FREETYPE_PROPERTIES="truetype:interpreter-version=35"

# set gtk theme for qt apps
#export QT_STYLE_OVERRIDE=GlobalQSS
#export QT_QPA_PLATFORMTHEME=gtk3

##################################################
# with original gtk3-classic
# https://github.com/lah7/gtk3-classic

# with gtk3-classic -> https://github.com/lah7/gtk3-classic/blob/master/csd__disabled-by-default.patch
# with gtk3-classic -> https://github.com/lah7/gtk3-classic/blob/master/csd__server-side-shadow.patch
# CSD windows are disabled by default
#  (unset/no) GTK_CSD : remove CSD (gtk3-classic default)
#    export GTK_CSD=0 : Normal GTK 3 behaviour (application decides)
#    export GTK_CSD=1 : forced CSDs (unusable with Mate v1.26, almost with v1.28.3)

# with gtk3-classic -> https://github.com/lah7/gtk3-classic/blob/master/other__default-settings.patch
# set scrollbars always visible... (gtk3-classic default) it's to be sure
export GTK_OVERLAY_SCROLLING=0

# with gtk3-classic -> https://github.com/lah7/gtk3-classic/blob/master/appearance__disable-backdrop.patch
# restore disabled backdrop state
export GTK_BACKDROP=1

# with gtk3-classic -> https://github.com/lah7/gtk3-classic/blob/master/other__hide-insert-emoji.patch
# restore disabled insert emoji menu item
export GTKM_INSERT_EMOJI=1

# with gtk3-classic -> https://github.com/lah7/gtk3-classic/blob/master/consistent_file_size_units-gtk3-patch
# use IEC units (open/save dialogs)
export GTK_USE_IEC_UNITS=1

##################################################
# with customized gtk3-classic and with gtk4-classic
# https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e

# with gtk3-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-appearance__focus-visible-gtk3-patch
# with gtk4-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-appearance__focus-visible-gtk4-patch
# restore visible focus (for example on first toolbar button)
export GTK_FOCUS_VISIBLE=1

# with gtk3-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-appearance__progress_text-gtk3-patch
# with gtk4-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-appearance__progress_text-gtk4-patch
# restore double text color for progress bars
export GTK_PROGRESS_TEXT_INSIDE=1

# with gtk4-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-consistent_file_size_units-gtk4-patch
# use IEC units (open/save dialogs)
# export GTK_USE_IEC_UNITS=1

# with gtk3-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-appearance__hide_treeview_lines-gtk3-patch
# disable treeview lines (for example vertical treeview lines in GtkInspector)
export GTK_TREEVIEW_LINES=0

# with gtk3-classic -> https://gist.github.com/luigifab/0fce786cdb93b5687069a82f490ea95e#file-scrollbar__extra_zone.gtk3.patch
# enlarges the active area for scroll bars (ultimate fix for https://github.com/mate-desktop/mate-desktop/issues/291)
export GTK_ENLARGE_SCROLLBAR=1
