#!/bin/bash



cd "$(dirname "$0")"
version="2.5.0"


mkdir -p builder builder/{BUILD,RPMS,SRPMS}
find builder/* ! -name "*$version*.rpm" ! -name "*$version*.gz" -exec rm -rf {} + 2>/dev/null


# copy to a tmp directory
if [ true ]; then
	rm human-theme-gtk.spec
	wget https://raw.githubusercontent.com/luigifab/human-theme/refs/tags/v$version/scripts/openmandriva/human-theme-gtk.spec
	chmod 644 human-theme-gtk.spec
	spectool -g -R human-theme-gtk.spec
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

	mv builder/$temp.tar.gz human-theme-gtk-$version.tar.gz
	chmod 644 human-theme-gtk.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
cp -a human-theme-gtk-$version.tar.gz human-theme-gtk.spec builder/
cd builder/
abb builda
rpm --addsign RPMS/*/human-theme-gtk*.rpm
rpm --addsign SRPMS/human-theme-gtk*.rpm
mv RPMS/*/human-theme-gtk*.rpm .
mv SRPMS/human-theme-gtk*.rpm .
echo "==========================="
rpm --checksig *.rpm
echo "==========================="
rpmlint human-theme-gtk.spec *.rpm
echo "==========================="
ls -dlth "$PWD/"*.rpm
echo "==========================="
cd ..

# cleanup
rm -rf builder/*/ builder/*buildlog builder/*spec human-theme-gtk-$version.tar.gz