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
	pattern="$1/qt*/*.qss"
else
	pattern="*/qt*/*.qss"
fi

for f in $pattern; do

	echo "Updating colors of $f..."

	if [[ "$f" != Human/* ]]; then
		echo " copy file from main theme..."
		cp "Human/${f#*/}" "$f"
	fi

	if [[ "$f" == */qt5/* ]]; then
		# cache valid for qt5 and qt6
		simpleCache=()
	fi

	# search and sort used colors from *.qss files
	# unique_colors=[@theme_selected_fg, @theme_text, ...]
	echo " extracting used colors..."
	colors=()
	while IFS= read -r match; do
		colors+=("$match")
	done < <(grep -oP '@\w+' "$f")

	mapfile -t unique_colors < <(printf "%s\n" "${colors[@]}" | sort -u)

	# search simple colors from gtk.css
	echo " searching simple colors..."
	IFS=$'\n'
	parent=$(dirname "$(dirname "$f")")
	simpleColors=$(grep 'define-color theme_' "$parent/gtk-3.0/gtk.css" | grep -v \()
	for color in $simpleColors; do

		# the color string (define-color keyword #XXX)
		color=${color/;/}              # | tr -d ";"
		color=${color/@define-color /} # | cut -c15-

		# $color = keyword #FFF
		if [[ -v simpleCache[$keyword] ]]; then
			continue
		elif [[ "$color" != *"@"* ]]; then
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
			if [[ ${#color} -eq 9 ]]; then
			    R=$((16#${color:1:2}))
			    G=$((16#${color:3:2}))
			    B=$((16#${color:5:2}))
			    A=$(awk "BEGIN {printf \"%.2f\", strtonum(\"0x${color:7:2}\")/255}")
			    color="rgba($R,$G,$B,$A)"
			fi
			echo " - $theAT » $color"
			simpleCache["$keyword"]="$color"
		else
			color="yellow"
		fi

		# #XYZ; /* @example */
		sedcmds+=( -e "s/#[a-zA-Z0-9]+; \/\* "$keyword" \*\//"$color"; \/\* "$keyword" \*\//g")
		# rgba(x,x,x,0.y); /* @example */
		sedcmds+=( -e "s/rgba\([^)]+\); \/\* "$keyword" \*\//"$color"; \/\* "$keyword" \*\//g")
		# @example; /* @example */
		sedcmds+=( -e "s/"$keyword"; \/\* "$keyword" \*\//"$color"; \/\* "$keyword" \*\//g")
		# @example */ #XYZ
		sedcmds+=( -e "s/"$keyword" \*\/ #[a-zA-Z0-9]+/"$keyword" \*\/ "$color"/g")
		# @example */ rgba(x,x,x,0.y)
		sedcmds+=( -e "s/"$keyword" \*\/ rgba\([^)]+\)/"$keyword" \*\/ "$color"/g")
		# @example */ @example
		sedcmds+=( -e "s/"$keyword" \*\/ "$keyword"/"$keyword" \*\/ "$color"/g")
	done

	# search and replace colors in *.qss
	echo " updating file..."
	sed -r -i "${sedcmds[@]}" $f
	echo " done"
	echo ""
	unset IFS
done