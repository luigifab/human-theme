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
shopt -s nullglob
shopt -s extglob

# made with the help of Claude
validTargets=(cinnamon firefox qt images)
validThemes=(Human Human-blue Human-green Human-orange Human-winxp)
filterTargets=()
filterTheme=""

show_help () {
	echo "Usage: $0 <target> [<target> ...] [theme]"
	echo ""
	echo "  target   one or more of: ${validTargets[*]}"
	echo "  theme    optional theme filter: ${validThemes[*]}"
	echo ""
}

show_step () {
	if false; then
		echo " $1"
	fi
}

list_contains () {
	local needle="$1"; shift
	local x
	for x in "$@"; do
		[[ "$x" == "$needle" ]] && return 0
	done
	return 1
}

do_target () {
	list_contains "$1" "${filterTargets[@]}"
}

if [ $# -eq 0 ]; then
	show_help
	exit 0
fi

for arg in "$@"; do
	if list_contains "$arg" "${validTargets[@]}"; then
		filterTargets+=("$arg")
	elif list_contains "$arg" "${validThemes[@]}"; then
		filterTheme="$arg"
	else
		echo "Warning: unknown argument: $arg"
	fi
done

if [[ ${#filterTargets[@]} -eq 0 ]]; then
	show_help
	exit 1
fi

if [ -n "$filterTheme" ]; then
	themes=("$filterTheme")
else
	themes=("${validThemes[@]}")
fi


# cinnamon
if do_target cinnamon; then

	for theme in "${themes[@]}"; do

		f="$theme/cinnamon/cinnamon.css"
		[ -f "$f" ] || continue

		echo "[cinnamon] Updating colors of $f..."

		if [[ "$f" != Human/* ]]; then
			show_step "copy file from main theme..."
			cp "Human/${f#*/}" "$f"
		fi

		# search and sort used colors from cinnamon.css
		# uniqueColors=[@theme_selected_fg, @theme_text, ...]
		show_step "extracting used colors..."
		mapfile -t uniqueColors < <(grep -ohP '@\w+' "$f" | sort -u | grep -v -e '@see' -e '@todo' -e '@media')

		# find all colors
		show_step "computing colors..."
		sedCmds=()
		batchResults=()

		if [[ ${#uniqueColors[@]} -gt 0 ]]; then

			mapfile -t batchResults < <(python3 colors.py "${uniqueColors[@]}" --theme "$theme")

			for i in "${!uniqueColors[@]}"; do

				keyword="${uniqueColors[i]}"
				color="${batchResults[i]:-}"

				if [ -z "$color" ]; then
					color="#FFFF00" # yellow
					echo -e " \e[90m- $keyword » yellow (ERROR)\e[0m"
				fi

				color=${color:0:7} # remove transparency #AABBCC[OO]

				# #XYZ; /* @example */
				sedCmds+=( -e "s/#[a-zA-Z0-9]+; \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# @example; /* @example */
				sedCmds+=( -e "s/$keyword; \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# @example */ #XYZ
				sedCmds+=( -e "s/$keyword \*\/ #[a-zA-Z0-9]+/$keyword \*\/ $color/g")
				# @example */ @example
				sedCmds+=( -e "s/$keyword \*\/ $keyword/$keyword \*\/ $color/g")
			done
		fi

		# search and replace colors in cinnamon.css
		# avoid arguments overflow with chunk
		show_step "updating file..."
		chunk=200
		for ((i=0; i<${#sedCmds[@]}; i+=chunk)); do
			sed -r -i "${sedCmds[@]:i:chunk}" $f  # sed -r -i "${sedCmds[@]}" $f
		done

		show_step "done"
	done
fi

# firefox
if do_target firefox; then

	for theme in "${themes[@]}"; do

		f="$theme/firefox/firefox.css"
		[ -f "$f" ] || continue

		echo "[firefox] Updating colors of $f..."

		if [[ "$f" != Human/* ]]; then
			show_step "copy file from main theme..."
			cp "Human/${f#*/}" "$f"
		fi

		# search and sort used colors from firefox.css
		# uniqueColors=[@theme_selected_fg, @theme_text, ...]
		show_step "extracting used colors..."
		mapfile -t uniqueColors < <(grep -ohP '@\w+' "$f" | sort -u | grep -v -e '@see' -e '@todo' -e '@media')

		# find all colors
		show_step "computing colors..."
		sedCmds=()
		batchResults=()

		if [[ ${#uniqueColors[@]} -gt 0 ]]; then

			mapfile -t batchResults < <(python3 colors.py "${uniqueColors[@]}" --theme "$theme")

			for i in "${!uniqueColors[@]}"; do

				keyword="${uniqueColors[i]}"
				color="${batchResults[i]:-}"

				if [ -z "$color" ]; then
					color="#FFFF00" # yellow
					echo -e " \e[90m- $keyword » yellow (ERROR)\e[0m"
				fi

				# #XYZ; /* @example */
				sedCmds+=( -e "s/#[a-zA-Z0-9]+; \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# #XYZ !important; /* @example */
				sedCmds+=( -e "s/#[a-zA-Z0-9]+ !important; \/\* $keyword \*\//$color !important; \/\* $keyword \*\//g")
				# @example; /* @example */
				sedCmds+=( -e "s/$keyword; \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# @example */ #XYZ
				sedCmds+=( -e "s/$keyword \*\/ #[a-zA-Z0-9]+/$keyword \*\/ $color/g")
				# @example */ @example
				sedCmds+=( -e "s/$keyword \*\/ $keyword/$keyword \*\/ $color/g")
			done
		fi

		# search and replace colors in firefox.css
		# avoid arguments overflow with chunk
		show_step "updating file..."
		chunk=200
		for ((i=0; i<${#sedCmds[@]}; i+=chunk)); do
			sed -r -i "${sedCmds[@]:i:chunk}" $f  # sed -r -i "${sedCmds[@]}" $f
		done

		show_step "done"
	done
fi

# qt
if do_target qt; then

	for theme in "${themes[@]}"; do
	for f in "$theme"/qt*/*.qss; do

		echo "[qt] Updating colors of $f..."

		if [[ "$f" != Human/* ]]; then
			show_step "copy file from main theme..."
			cp "Human/${f#*/}" "$f"
		fi

		# search and sort used colors from *.qss files
		# uniqueColors=[@theme_selected_fg, @theme_text, ...]
		show_step "extracting used colors..."
		mapfile -t uniqueColors < <(grep -ohP '@\w+' "$f" | sort -u | grep -v -e '@see' -e '@todo' -e '@media')

		# find all colors
		show_step "computing colors..."
		sedCmds=()
		batchResults=()

		if [[ ${#uniqueColors[@]} -gt 0 ]]; then

			mapfile -t batchResults < <(python3 colors.py "${uniqueColors[@]}" --theme "$theme")

			for i in "${!uniqueColors[@]}"; do

				keyword="${uniqueColors[i]}"
				color="${batchResults[i]:-}"

				if [ -z "$color" ]; then
					color="#FFFF00" # yellow
					echo -e " \e[90m- $keyword » yellow (ERROR)\e[0m"
				elif [[ ${#color} -eq 9 ]]; then
					# replace #RRGGBBAA by rgba(r,g,b,a)
					R=$((16#${color:1:2}))
					G=$((16#${color:3:2}))
					B=$((16#${color:5:2}))
					if [[ "$f" = */qt4/* ]]; then
						A=$((16#${color:7:2}))
					else
						n=$(( (16#${color:7:2} * 1000 / 255 + 5) / 10 ))
						A=$(printf '%d.%02d' $((n/100)) $((n%100)))
					fi
					color="rgba($R,$G,$B,$A)"
				fi

				# #XYZ; /* @example */
				sedCmds+=( -e "s/#[a-zA-Z0-9]+; \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# rgba(x,x,x,0.y); /* @example */
				sedCmds+=( -e "s/rgba\([^)]+\); \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# @example; /* @example */
				sedCmds+=( -e "s/$keyword; \/\* $keyword \*\//$color; \/\* $keyword \*\//g")
				# @example */ #XYZ
				sedCmds+=( -e "s/$keyword \*\/ #[a-zA-Z0-9]+/$keyword \*\/ $color/g")
				# @example */ rgba(x,x,x,0.y)
				sedCmds+=( -e "s/$keyword \*\/ rgba\([^)]+\)/$keyword \*\/ $color/g")
				# @example */ @example
				sedCmds+=( -e "s/$keyword \*\/ $keyword/$keyword \*\/ $color/g")
			done
		fi

		# search and replace colors in *.qss
		# avoid arguments overflow with chunk
		show_step "updating file..."
		chunk=200
		for ((i=0; i<${#sedCmds[@]}; i+=chunk)); do
			sed -r -i "${sedCmds[@]:i:chunk}" $f  # sed -r -i "${sedCmds[@]}" $f
		done

		show_step "done"
	done
	done
fi

# images
if do_target images; then

	for theme in "${themes[@]}"; do

		f="$theme/gtk-3.0/gtk.css"
		[ -f "$f" ] || continue

		echo "[images] With colors of $f..."

		# copy missing svg files
		if [[ "$f" != Human/* ]]; then
			show_step "copying missing files..."
			destDir="$(dirname "$f")/../images"
			for src in Human/images/*.svg; do
				base="$(basename "$src")"
				if [ ! -f "$destDir/$base" ]; then
					cp "$src" "$destDir/$base"
					echo " - added $base"
				fi
			done
		fi

		svgs="$(dirname "$f")/../images/*.svg"

		# search and sort used colors from *.svg files
		# uniqueColors=[@theme_selected_fg, @theme_text, ...]
		show_step "extracting used colors..."
		mapfile -t uniqueColors < <(grep -ohP '"[^"]*"\s+class="\K[^"]*' $svgs | sed 's/^/@/' | sort -u | grep -v -e '@see' -e '@todo' -e '@media')

		# find all colors
		show_step "computing colors..."
		sedCmds=()
		batchResults=()

		if [[ ${#uniqueColors[@]} -gt 0 ]]; then

			mapfile -t batchResults < <(python3 colors.py "${uniqueColors[@]}" --theme "$theme")

			for i in "${!uniqueColors[@]}"; do

				keyword="${uniqueColors[i]}"
				color="${batchResults[i]:-}"

				if [ -z "$color" ]; then
					color="#FFFF00" # yellow
					echo -e " \e[90m- $keyword » yellow (ERROR)\e[0m"
				fi

				color=${color:0:7} # remove transparency #AABBCC[OO]

				# "#XXX" class="keyword"
				keyword=${keyword:1}
				sedCmds+=( -e "s/\"#[a-zA-Z0-9]+\" class=\"$keyword\"/\"$color\" class=\"$keyword\"/g")
			done
		fi

		# refresh file then search and replace colors in *.svg
		show_step "updating files..."
		cnts=0
		for svg in $svgs; do

			md5Orig=$(md5sum "$svg"); md5Orig=${md5Orig%% *}
			if [[ "$f" != Human/* ]]; then
				cp "Human/${svg#*/}" "$svg"
			fi
			sed -r -i "${sedCmds[@]}" $svg
			md5New=$(md5sum "$svg"); md5New=${md5New%% *}

			if [ "$md5Orig" != "$md5New" ]; then
				echo " - updated $svg"
				((cnts++))
			fi
		done

		show_step "done ($cnts files updated)"
	done
fi
