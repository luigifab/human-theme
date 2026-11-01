#!/bin/bash
# Copyright 2020-2027 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://github.com/luigifab/human-theme
#
# Forked from
#  Copyright 2020 | Mike Kazantsev (mk-fg) <mk~fraggod~gmail~com>
#  https://github.com/mk-fg/clearlooks-phenix-humanity
#
# Forked from
#  Copyright 2011-2014 | Jean-Philippe Fleury
#  Copyright 2013-2014 | Andrew Shadura
#  https://github.com/jpfleury/clearlooks-phenix
#
# This program is free software, you can redistribute it or modify
# it under the terms of the GNU General Public License (GPL) as published
# by the free software foundation, either version 3 of the license, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but without any warranty, without even the implied warranty of
# merchantability or fitness for a particular purpose. See the
# GNU General Public License (GPL) for more details.

cd "$(dirname "$0")" || exit 1
set -euo pipefail

# made by Claude (sudo apt install xdotool imagemagick x11-utils)
OUTDIR="$(pwd)/images"
THUMBDIR="$OUTDIR/thumbs"
APPS=("awf-gtk2" "awf-gtk3" "env GDK_DISABLE=gl,vulkan GSK_RENDERER=cairo awf-gtk4" "awf-qt4" "awf-qt5" "awf-qt6")
COLORS=("" "blue" "orange" "green")
RTLFLAGS=(0 1)
DELAY_LAUNCH=2
DELAY_MENU=1
DELAY_FIREFOX=8
FIREFOX_PROFILE="test"
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox/90mc73q8.${FIREFOX_PROFILE}"
FIREFOX_CHROME_DIR="${FIREFOX_PROFILE_DIR}/chrome"
FIREFOX_CSS_BASE="$(pwd)"

mkdir -p "$OUTDIR" "$THUMBDIR"

capture_window_area() {
	sleep "$DELAY_MENU"
	local wid="$1" outfile="$2"
	local info absx absy left top w h right bottom extents

	info=$(LC_ALL=C.UTF-8 xwininfo -id "$wid")

	absx=$(echo "$info" | awk '/Absolute upper-left X/ {print $4}')
	absy=$(echo "$info" | awk '/Absolute upper-left Y/ {print $4}')
	w=$(echo "$info" | awk '/^ *Width:/ {print $2}')
	h=$(echo "$info" | awk '/^ *Height:/ {print $2}')

	extents=$(LC_ALL=C.UTF-8 xprop -id "$wid" _NET_FRAME_EXTENTS 2>/dev/null | awk -F'= ' '{print $2}')
	if [ -n "$extents" ]; then
		IFS=', ' read -r left right top bottom <<< "$extents"
	else
		left=0; right=0; top=0; bottom=0
	fi

	X=$((absx - left))
	Y=$((absy - top))
	WIDTH=$((w + left + right))
	HEIGHT=$((h + top + bottom))

	import -window root -crop "${WIDTH}x${HEIGHT}+${X}+${Y}" "$outfile"
	local tmbfile="$THUMBDIR/$(basename "$outfile")"
	convert "$outfile" -resize 400x "$tmbfile"
	echo "  $outfile"
}

start_app() {
	local delay="$1"; shift
	"$@" &
	pid=$!
	sleep "$delay"

	wid=$(xdotool search --pid "$pid" --onlyvisible | head -1) || true
	if [ -z "$wid" ]; then
		kill "$pid" 2>/dev/null || true
		return 1
	fi
	xdotool windowactivate "$wid"
}

stop_app() {
	kill "$pid" 2>/dev/null || true
	wait "$pid" 2>/dev/null || true
}

# awf-gtk & awf-qt
for app_entry in "${APPS[@]}"; do

	read -ra cmd <<< "$app_entry"
	bin="${cmd[-1]}"
	applabel="${bin#awf-}"
	echo "$app_entry"

	for color in "${COLORS[@]}"; do

		theme="Human${color:+-$color}"
		gsettings set org.mate.Marco.general theme "ClearlooksRe"
		gsettings set org.mate.interface gtk-theme "$theme"
		echo " $theme"
		sleep "$DELAY_MENU"

		for rtl in "${RTLFLAGS[@]}"; do

			args=()
			fileprefix="$applabel"
			if [ "$rtl" = 1 ]; then
				if [[ "$bin" == awf-qt* ]]; then
					args+=(--reverse)
				else
					args+=(--rtl)
				fi
				fileprefix="${fileprefix}-rtl"
			fi
			fileprefix="${fileprefix}${color:+-$color}"

			LC_ALL=C.UTF-8 start_app "$DELAY_LAUNCH" "${cmd[@]}" "${args[@]}" || continue
			capture_window_area "$wid" "${OUTDIR}/${fileprefix}.png"

			xdotool key alt+o
			capture_window_area "$wid" "${OUTDIR}/${fileprefix}-menu.png"
			xdotool key Escape
			stop_app
		done

		if [ "$bin" = "awf-gtk3" ]; then

			LC_ALL=C.UTF-8 start_app "$DELAY_LAUNCH" "${cmd[@]}" || continue
			xdotool key Right Right Right Right Right Return
			capture_window_area "$wid" "${OUTDIR}/gtk3-plus${color:+-$color}.png"
			stop_app

			GTK_CSD=1 LC_ALL=C.UTF-8 start_app "$DELAY_LAUNCH" "${cmd[@]}" || continue
			capture_window_area "$wid" "${OUTDIR}/gtk3-csd${color:+-$color}.png"
			stop_app
		fi
	done
done

# firefox
for color in "${COLORS[@]}"; do

	theme="Human${color:+-$color}"
	gsettings set org.mate.Marco.general theme "ClearlooksRe"
	gsettings set org.mate.interface gtk-theme "$theme"
	echo " $theme"
	sleep "$DELAY_MENU"

	ln -sf "${FIREFOX_CSS_BASE}/${theme}/firefox/firefox.css" "${FIREFOX_CHROME_DIR}/userChrome.css"

	fileprefix="firefox${color:+-$color}"
	LC_ALL=C.UTF-8 start_app "$DELAY_FIREFOX" firefox -no-remote -P "$FIREFOX_PROFILE" || continue
	capture_window_area "$wid" "${OUTDIR}/${fileprefix}.png"

	xdotool key alt+f
	capture_window_area "$wid" "${OUTDIR}/${fileprefix}-menu.png"
	xdotool key Escape
	stop_app
done

# reset
gsettings set org.mate.Marco.general theme "ClearlooksRe"
gsettings set org.mate.interface gtk-theme "Human"
ln -sf "${FIREFOX_CSS_BASE}/Human/firefox/firefox.css" "${FIREFOX_CHROME_DIR}/userChrome.css"
