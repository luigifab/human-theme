#!/bin/bash



cd "$(dirname "$0")"
version="2.3.0"


mkdir -p builder builder/{BUILD,RPMS,SRPMS}
find builder/* ! -name "*$version*.rpm" ! -name "*$version*.gz" -exec rm -rf {} + 2>/dev/null

# copy to a tmp directory
if [ true ]; then
	chmod 644 human-gtk-theme.spec
	spectool -g -R human-gtk-theme.spec
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

	mv builder/$temp.tar.gz human-gtk-theme-$version.tar.gz
	chmod 644 human-gtk-theme.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
cp -a human-gtk-theme-$version.tar.gz human-gtk-theme.spec builder/
cd builder/
abb builda
rpm --addsign RPMS/*/human-gtk-theme*.rpm
rpm --addsign SRPMS/human-gtk-theme*.rpm
mv RPMS/*/human-gtk-theme*.rpm .
mv SRPMS/human-gtk-theme*.rpm .
echo "==========================="
rpm --checksig *.rpm
echo "==========================="
rpmlint human-gtk-theme.spec *.rpm
echo "==========================="
ls -dlth "$PWD/"*.rpm
echo "==========================="
cd ..

# cleanup
rm -rf builder/*/ builder/*buildlog builder/*spec