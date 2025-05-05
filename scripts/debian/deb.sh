#!/bin/bash
# Debian: sudo apt install dpkg-dev devscripts dh-make


cd "$(dirname "$0")"
version="2.4.0"


mkdir builder
rm -rf builder/*

# copy to a tmp directory
if [ true ]; then
	cd builder
	wget https://github.com/luigifab/human-theme/archive/v$version/human-theme-$version.tar.gz
	tar xzf human-theme-$version.tar.gz
	cd ..
else
	temp=human-theme-$version
	mkdir /tmp/$temp
	cp -r ../../* /tmp/$temp/
	rm -rf /tmp/$temp/scripts/*/builder/

	mv /tmp/$temp builder/
	cp /usr/share/common-licenses/GPL*3 builder/$temp/LICENSE

	cd builder/
	tar czf $temp.tar.gz $temp
	cd ..
fi


# create packages for Debian and Ubuntu and MX Linux
for serie in experimental questing plucky oracular noble jammy focal bionic xenial trusty mx23; do

	printf "\n\n#################################################################### $serie ##\n\n"
	if [ $serie = "experimental" ]; then
		# copy for Ubuntu
		cp -a builder/human-theme-$version/ builder/human-theme-$version+src/
		cd builder/human-theme-$version/
	elif [ $serie = "unstable" ]; then
		rm -rf builder/human-theme-$version/
		cp -a builder/human-theme-$version+src/ builder/human-theme-$version/
		cd builder/human-theme-$version/
	else
		cp -a builder/human-theme-$version+src/ builder/human-theme-$serie-$version/
		cd builder/human-theme-$serie-$version/
	fi

	dh_make -s -y -f ../human-theme-$version.tar.gz -p human-theme-gtk

	rm -rf debian/*/*ex debian/*ex debian/*EX debian/README* debian/*doc*
	cp scripts/debian/* debian/
	rm -f debian/deb.sh
	mkdir debian/upstream ; mv debian/metadata debian/upstream/metadata



	if [ $serie = "experimental" ]; then
		mv debian/control.debian debian/control
		mv debian/changelog.debian debian/changelog
		echo "=========================== buildpackage ($serie) =="
		dpkg-buildpackage -us -uc
	else
		# debhelper: experimental:13 focal/mx19/mx21:12 bionic:9 xenial:9 trusty:9
		if [ $serie = "unstable" ]; then
			mv debian/control.debian debian/control

		elif [ $serie = "mx19" ] || [ $serie = "mx21" ]; then
			mv debian/control.mx debian/control
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/g' debian/control
		elif [ $serie = "focal" ]; then
			mv debian/control.ubuntu debian/control
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/g' debian/control
		elif [ $serie = "bionic" ]; then
			mv debian/control.ubuntu debian/control

			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 9)/g' debian/control
		elif [ $serie = "xenial" ]; then
			mv debian/control.ubuntu debian/control

			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		elif [ $serie = "trusty" ]; then
			mv debian/control.ubuntu debian/control
			sed -i 's/dh $@/dh $@ --with autotools_dev/g' debian/rules
			sed -i 's/override_dh_update_autotools_config/override_dh_autotools-dev_updateconfig/g' debian/rules
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9), autotools-dev/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		else
			mv debian/control.ubuntu debian/control
		fi
		if [ $serie = "mx23" ] || [ $serie = "mx21" ] || [ $serie = "mx19" ]; then
			mv debian/changelog.mx debian/changelog
			sed -i 's/-1) /-1~'$serie'+1) /' debian/changelog
		elif [ $serie = "unstable" ]; then
			mv debian/changelog.debian debian/changelog
		else
			mv debian/changelog.ubuntu debian/changelog
			sed -i 's/experimental/'$serie'/g' debian/changelog
			sed -i 's/-1) /-1+'$serie') /' debian/changelog
		fi
		rm -f debian/*.mx debian/*.debian debian/*.ubuntu
		echo "=========================== buildpackage ($serie) =="
		dpkg-buildpackage -us -uc -ui -d -S
	fi
	echo "=========================== debsign ($serie) =="
	cd ..

	if [ $serie = "experimental" ]; then
		debsign human-theme-gtk_$version*.changes
		echo "=========================== lintian ($serie) =="
		lintian -EviIL +pedantic human-theme-gtk_$version*.changes
	elif [ $serie = "unstable" ]; then
		debsign human-theme-gtk*$version-*_source.changes
	else
		debsign human-theme-gtk*$version*$serie*source.changes
	fi
	cd ..
done

printf "\n\n"
ls -dlth "$PWD/"builder/*.deb "$PWD/"builder/*.changes
printf "\n"
rm -rf builder/*/