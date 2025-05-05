#!/bin/bash

cd "$(dirname "$0")"
for f in */gtk-3.0/gtk.css; do

	svgs="$(dirname "$f")/img/*.svg"
	cnts=($svgs)
	cnts=${#cnts[@]}

	echo "With colors of $f..."
	echo " there are $cnts images"

	IFS=$'\n'
	count=0
	colors=$(grep 'define-color theme_' $f | grep -v \()

	theme=$(basename "$(dirname "$(dirname "$f")")")

	for color in $colors; do

		# the color string (define-color keyword #XXX)
		color=${color/;/}              # | tr -d ";"
		color=${color/@define-color /} # | cut -c15-

		# $color = keyword #FFF  or  keyword @xyz
		# translate the color
		if [[ "$color" == *"@"* ]]; then
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

		# search and replace in theme images
		for svg in $svgs; do

			original_md5=$(md5sum "$svg" | awk '{print $1}')
			sed -r -i 's/"#[a-zA-Z0-9]+" class="'$class'"/'$replace'/g' $svg
			new_md5=$(md5sum "$svg" | awk '{print $1}')

			if [ "$original_md5" != "$new_md5" ]; then
				echo " updated $svg"
				((count++))
			fi
		done
	done

	echo " $count svg updated"
	unset IFS
done