#!/bin/bash
# debian: sudo apt install dpkg-dev devscripts dh-make rpm
# fedora: sudo dnf install rpmdevtools rpm-sign
# fedora: configure: error: C compiler cannot create executables? remove and reinstall glibc-devel gcc

cd "$(dirname "$0")"
version="1.2.0"


rm -rf builder/ ~/rpmbuild/
mkdir -p builder ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# copy to a tmp directory
if [ true ]; then
	chmod 644 human-theme-gtk.spec
	spectool -g -R human-theme-gtk.spec
else
	temp=human-theme-${version}
	mkdir /tmp/${temp}
	cp -r ../* /tmp/${temp}/
	rm -rf /tmp/${temp}/*/builder/

	mv /tmp/${temp} builder/
	cp /usr/share/common-licenses/GPL-3 builder/${temp}/LICENSE

	cd builder/
	tar czf ${temp}.tar.gz ${temp}
	cd ..

	cp builder/${temp}.tar.gz ~/rpmbuild/SOURCES/human-theme-gtk-${version}.tar.gz
	chmod 644 human-theme-gtk.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
rpmbuild --nodeps -ba human-theme-gtk.spec
rpm --addsign ~/rpmbuild/RPMS/*/*.rpm
rpm --addsign ~/rpmbuild/SRPMS/*.rpm
mv ~/rpmbuild/RPMS/*/*.rpm builder/
mv ~/rpmbuild/SRPMS/*.rpm builder/
echo "==========================="
rpm --checksig builder/*.rpm
echo "==========================="
rpmlint human-theme-gtk.spec builder/*.rpm
echo "==========================="
ls -dltrh $PWD/builder/*.rpm
echo "==========================="

# cleanup
rm -rf builder/*/ ~/rpmbuild/