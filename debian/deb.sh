#!/bin/bash
# debian: sudo apt install dpkg-dev devscripts dh-make


cd "$(dirname "$0")"
version="1.4.0"


rm -rf builder/
mkdir builder

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


# create packages for debian and ubuntu
for serie in unstable impish hirsute groovy focal bionic xenial trusty precise; do

	if [ $serie = "unstable" ]; then
		# for ubuntu
		cp -a builder/human-theme-$version/ builder/human-theme-$version+src/
		# debian only
		cd builder/human-theme-$version/
	else
		# ubuntu only
		cp -a builder/human-theme-$version+src/ builder/human-theme-$version+$serie/
		cd builder/human-theme-$version+$serie/
	fi

	dh_make -a -s -y -f ../human-theme-$version.tar.gz -p human-theme-gtk

	rm -f debian/*ex debian/*EX debian/README* debian/*doc*
	mkdir debian/upstream
	mv debian/metadata debian/upstream/metadata




	if [ $serie = "unstable" ]; then
		dpkg-buildpackage -us -uc
	else
		# debhelper: unstable:13 hirsute:13 groovy:13 focal:12 bionic:9 xenial:9 trusty:9 precise:9
		if [ $serie = "focal" ]; then
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
		if [ $serie = "precise" ]; then
			sed -i 's/dh $@/dh $@ --with autotools_dev/g' debian/rules
			sed -i 's/override_dh_update_autotools_config/override_dh_autotools-dev_updateconfig/g' debian/rules
			sed -i 's/debhelper-compat (= 13)/debhelper (>= 9), autotools-dev/g' debian/control
			sed -i ':a;N;$!ba;s/Rules-Requires-Root: no\n//g' debian/control
			echo 9 > debian/compat
		fi
		sed -i 's/unstable/'$serie'/g' debian/changelog
		sed -i 's/-1) /-1+'$serie') /' debian/changelog
		dpkg-buildpackage -us -uc -ui -d -S
	fi
	echo "==========================="
	cd ..

	if [ $serie = "unstable" ]; then
		# debian only
		debsign human-theme-gtk_$version-*.changes
		echo "==========================="
		lintian -EviIL +pedantic human-theme-gtk_$version-*.deb
	else
		# ubuntu only
		debsign human-theme-gtk_$version*+$serie*source.changes
	fi
	echo "==========================="
	cd ..
done

ls -dltrh builder/*.deb builder/*.changes
echo "==========================="

# cleanup
rm -rf builder/*/