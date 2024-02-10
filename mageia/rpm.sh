#!/bin/bash
# Mageia: sudo urpmi --no-recommends rpmdevtools rpmlint rpmlint-mageia-policy rpm-sign aspell-fr enchant2-aspell


cd "$(dirname "$0")"
version="2.2.0"


mkdir -p builder ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
find builder/* ! -name "*$version*.rpm" ! -name "*$version*.gz" -exec rm -rf {} + 2>/dev/null

# copy to a tmp directory
if [ true ]; then
	chmod 644 human-theme-gtk.spec
	spectool -g -R human-theme-gtk.spec
else
	temp=human-theme-$version
	mkdir /tmp/$temp
	cp -r ../* /tmp/$temp/
	rm -rf /tmp/$temp/*/builder/

	mv /tmp/$temp builder/
	cp /usr/share/common-licenses/GPLv3 builder/$temp/LICENSE

	cd builder/
	tar czf $temp.tar.gz $temp
	cd ..

	cp builder/$temp.tar.gz ~/rpmbuild/SOURCES/human-theme-gtk-$version.tar.gz
	chmod 644 human-theme-gtk.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
rpmbuild -ba human-theme-gtk.spec
rpm --addsign ~/rpmbuild/RPMS/*/human-theme-gtk*.rpm
rpm --addsign ~/rpmbuild/SRPMS/human-theme-gtk*.rpm
mv ~/rpmbuild/RPMS/*/human-theme-gtk*.rpm builder/
mv ~/rpmbuild/SRPMS/human-theme-gtk*.rpm builder/
echo "==========================="
rpm --checksig builder/*.rpm
echo "==========================="
rpmlint human-theme-gtk.spec builder/*.rpm
echo "==========================="
ls -dlth "$PWD/"builder/*.rpm
echo "==========================="

# cleanup
rm -rf builder/*/