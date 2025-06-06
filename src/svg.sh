#!/bin/bash
# Copyright 2020-2025 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
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

cd "$(dirname "$0")"
for f in */gtk-3.0/gtk.css; do

	svgs="$(dirname "$f")/img/*.svg"
	cnts=($svgs)
	cnts=${#cnts[@]}

	echo "With colors of $f..."
	echo " there are $cnts images"

	IFS=$'\n'
	sedcmds=()
	count=0
	theme=$(basename "$(dirname "$(dirname "$f")")")

	# find colors
	echo " computing colors..."
	colors=$(grep 'define-color theme_' $f | grep -v \()
	for color in $colors; do

		# the color string (define-color keyword #XXX)
		color=${color/;/}              # | tr -d ";"
		color=${color/@define-color /} # | cut -c15-

		# $color = keyword #FFF  or  keyword @xyz
		# translate the color
		if [[ "$keyword" == *"@see"* ]]; then
			continue
		elif [[ "$keyword" == *"@todo"* ]]; then
			continue
		elif [[ "$color" == *"@"* ]]; then
			theAT="${color#* }"
			tmp=$(python3 color.py "$theAT" --theme $theme)
			prefix="${color%% *}"
			color="$prefix $tmp"
		fi

		# the replace string ("#XXX" class="keyword")
		replace=$color
		regex='(theme_[a-z0-9_]+) (#[a-zA-Z0-9]+)'
		while [[ $replace =~ $regex ]]; do
			class=${BASH_REMATCH[1]}
			replace="\"${BASH_REMATCH[2]}\" class=\"${BASH_REMATCH[1]}\""
		done

		# the regex
		sedcmds+=( -e "s/\"#[a-zA-Z0-9]+\" class=\""$class"\"/"$replace"/g")
	done

	# search and replace
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
	unset IFS
done