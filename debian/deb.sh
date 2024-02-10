#!/bin/bash
# Debian: sudo apt install dpkg-dev devscripts dh-make


cd "$(dirname "$0")"
version="2.2.0"


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
	cp -r ../* /tmp/$temp/
	rm -rf /tmp/$temp/*/builder/

	mv /tmp/$temp builder/
	cp /usr/share/common-licenses/GPL-3 builder/$temp/LICENSE

	cd builder/
	tar czf $temp.tar.gz $temp
	cd ..
fi


# create packages for Debian and Ubuntu and MX Linux
for serie in experimental noble mantic jammy focal bionic xenial trusty mx23 mx21 mx19; do

	if [ $serie = "experimental" ]; then
		# copy for Ubuntu
		cp -a builder/human-theme-$version/ builder/human-theme-$version+src/
		# Debian only
		cd builder/human-theme-$version/
	else
		# Ubuntu only
		cp -a builder/human-theme-$version+src/ builder/human-theme-$version+$serie/
		cd builder/human-theme-$version+$serie/
	fi

	dh_make -a -s -y -f ../human-theme-$version.tar.gz -p human-theme-gtk

	rm -f debian/*ex debian/*EX debian/README* debian/*doc*
	mkdir debian/upstream
	rm debian/deb.sh
	mv debian/metadata debian/upstream/metadata




	if [ $serie = "experimental" ]; then
		dpkg-buildpackage -us -uc
	else
		# debhelper: experimental:13 focal:12 bionic:9 xenial:9 trusty:9
		if [ $serie = "focal" ] || [ $serie = "mx19" ] || [ $serie = "mx21" ]; then
			if [ $serie = "mx19" ] || [ $serie = "mx21" ]; then
				mv debian/control.mx debian/control
			fi
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/g' debian/control
		fi
		if [ $serie = "bionic" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 9)/g' debian/control
		fi
		if [ $serie = "xenial" ]; then
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9)/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		fi
		if [ $serie = "trusty" ]; then
			sed -i 's/dh $@/dh $@ --with autotools_dev/g' debian/rules
			sed -i 's/override_dh_update_autotools_config/override_dh_autotools-dev_updateconfig/g' debian/rules
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9), autotools-dev/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		fi
		if [ $serie = "mx23" ] || [ $serie = "mx21" ] || [ $serie = "mx19" ]; then
			# MX Linux only
			mv debian/changelog.mx debian/changelog
			sed -i 's/-1) /-1~'$serie'+1) /' debian/changelog
		else
			rm -f debian/*.mx
			sed -i 's/experimental/'$serie'/g' debian/changelog
			sed -i 's/-1) /-1+'$serie') /' debian/changelog
		fi
		dpkg-buildpackage -us -uc -ui -d -S
	fi
	echo "=========================== debsign =="
	cd ..

	if [ $serie = "experimental" ]; then
		# Debian only
		debsign human-theme-gtk_$version*.changes
		echo "=========================== lintian =="
		lintian -EviIL +pedantic human-theme-gtk*$version*.deb
	else
		# Ubuntu only
		debsign human-theme-gtk*$version*$serie*source.changes
	fi
	echo "==========================="
	cd ..
done

ls -dlth "$PWD/"builder/*.deb "$PWD/"builder/*.changes
echo "==========================="

# cleanup
rm -rf builder/*/