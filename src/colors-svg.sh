#!/bin/bash
# Copyright 2020-2026 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

shopt -s nullglob
shopt -s extglob
declare -A simpleCache

cd "$(dirname "$0")"

if [ -n "$1" ]; then
	pattern="$1/gtk-3.0/gtk.css"
else
	pattern="*/gtk-3.0/gtk.css"
fi

for f in $pattern; do

	svgs="$(dirname "$f")/img/*.svg"
	cnts=($svgs)
	cnts=${#cnts[@]}

	echo "With colors of $f..."
	echo " there are $cnts images"

	# search and sort used colors from *.svg files
	# unique_colors=[@theme_selected_fg, @theme_text, ...]
	echo " extracting used colors..."
	colors=()
	while IFS= read -r match; do
		colors+=("@$(grep -oP 'class="\K[^"]*' <<< "$match")")
	done < <(grep -oP '"[^"]*"\s+class="[^"]*"' $svgs)

	mapfile -t unique_colors < <(printf "%s\n" "${colors[@]}" | sort -u)

	# search simple colors from gtk.css
	echo " searching simple colors..."
	IFS=$'\n'
	parent=$(dirname "$(dirname "$f")")
	simpleColors=$(grep 'define-color theme_' "$parent/gtk-3.0/gtk.css" | grep -v \()
	simpleCache=()
	for color in $simpleColors; do

		# the color string (define-color keyword #XXX)
		color=${color/;/}              # | tr -d ";"
		color=${color/@define-color /} # | cut -c15-

		# $color = keyword #FFF
		if [[ "$color" != *"@"* ]]; then
			keyword="@${color%% *}"
			color="${color#* }"
			simpleCache["$keyword"]="$color"
		fi
	done

	# find all colors
	echo " computing colors..."
	theme=$(basename "$(dirname "$(dirname "$f")")")
	sedcmds=()
	for keyword in "${unique_colors[@]}"; do

		if [[ -v simpleCache[$keyword] ]]; then
			color="${simpleCache[$keyword]}"
		elif [[ "$keyword" == *"@see"* ]]; then
			continue
		elif [[ "$keyword" == *"@todo"* ]]; then
			continue
		elif [[ "$keyword" == *"@"* ]]; then
			theAT="${keyword#* }"
			color=$(python3 color.py "$theAT" --theme $theme)
			echo " - $theAT » $color"
		else
			color="yellow"
		fi

		# "#XXX" class="keyword"
		keyword=${keyword:1}
		sedcmds+=( -e "s/\"[#a-zA-Z0-9]+\" class=\""$keyword"\"/\""$color"\" class=\""$keyword"\"/g")
	done

	# search and replace colors in *.svg
	count=0
	echo " updating files..."
	for svg in $svgs; do

		original_md5=$(md5sum "$svg" | awk '{print $1}')
		sed -r -i "${sedcmds[@]}" $svg
		new_md5=$(md5sum "$svg" | awk '{print $1}')

		if [ "$original_md5" != "$new_md5" ]; then
			echo " - updated $svg"
			((count++))
		fi
	done

	echo " $count svg updated"
	echo ""
	unset IFS
done