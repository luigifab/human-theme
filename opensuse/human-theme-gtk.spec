Name:          human-theme-gtk
Version:       2.1.0
Release:       0
Summary:       Human theme for GTK
Summary(fr):   Thème Human pour GTK
License:       GPL-3.0-or-later and LGPL-2.1-or-later and CC-BY-SA-3.0
URL:           https://github.com/luigifab/human-theme
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: aspell-fr
Recommends:    dmz-cursor-themes
Recommends:    gnome-icon-theme
Recommends:    gtk2-engine-murrine
Suggests:      libqt5-qtbase-platformtheme-gtk3
Suggests:      libqt5-qtstyleplugins-platformtheme-gtk2
Suggests:      qt6-platformtheme-gtk3
# https://software.openSUSE.org/search?baseproject=openSUSE%3AFactory&q=qt+theme+gtk

%description %{expand:
This theme works with: GTK 2.24+ (with gtk2-engine-murrine),
GTK 3.20+ (including 3.22 and 3.24), and GTK 4.0+. It is mainly
intended for Mate and Xfce Desktop Environments.

After installation you must restart your session.}

%description -l fr %{expand:
Ce thème fonctionne avec : GTK 2.24+ (avec gtk2-engine-murrine),
GTK 3.20+ (y compris 3.22 et 3.24), et GTK 4.0+. Il est principalement
destiné pour les environnements de bureau Mate et Xfce.

Après l'installation vous devez redémarrer votre session.}


%prep
%setup -q -n human-theme-%{version}

%build

%install
mkdir -p %{buildroot}%{_sysconfdir}/profile.d/
mkdir -p %{buildroot}%{_datadir}/themes/
install -p -m 644 debian/profile.sh %{buildroot}%{_sysconfdir}/profile.d/%{name}.sh
cp -a src/human-theme/        %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-blue/   %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-green/  %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-orange/ %{buildroot}%{_datadir}/themes/

%files
%config(noreplace) %{_sysconfdir}/profile.d/%{name}.sh
%license LICENSE
%doc README.md
# the entire source code is GPL-3.0-or-later, except metacity-1/* which is LGPL-2.1-or-later, and gtk-2.0/* which is CC-BY-SA-3.0+
%{_datadir}/themes/human-theme/
%{_datadir}/themes/human-theme-blue/
%{_datadir}/themes/human-theme-green/
%{_datadir}/themes/human-theme-orange/

%triggerin -- pango
currentver=`rpm -qa --queryformat '%{VERSION}' pango`
required50=1.50
required44=1.44
# https://unix.stackexchange.com/a/285928
if [ "$(printf '%s\n' "$required50" "$currentver" | sort -V | head -n1)" = "$required50" ]; then
  # Pango >= 1.50 (same as Pango < 1.44)
  echo "Update %{name} for Pango >= 1.50"
  sed -i 's/<border name="title_border" left="2" right="2" top="4" bottom="4"/<border name="title_border" left="2" right="2" top="4" bottom="3"/g' /usr/share/themes/human-theme/metacity-1/metacity-theme-1.xml
  sed -i 's/padding: 4px 3px 2px; \/\* WARNING/padding: 4px 3px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
  sed -i 's/padding: 3px 3px 2px; \/\* WARNING/padding: 3px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
  sed -i 's/margin: -7px -10px -5px; \/\* WARNING/margin: -7px -10px -4px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
elif [ "$(printf '%s\n' "$required44" "$currentver" | sort -V | head -n1)" = "$required44" ]; then
  # Pango 1.44..1.49
  echo "Update %{name} for Pango >= 1.44 and < 1.50"
  sed -i 's/<border name="title_border" left="2" right="2" top="4" bottom="3"/<border name="title_border" left="2" right="2" top="4" bottom="4"/g' /usr/share/themes/human-theme/metacity-1/metacity-theme-1.xml
  sed -i 's/padding: 4px 3px; \/\* WARNING/padding: 4px 3px 2px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
  sed -i 's/padding: 3px; \/\* WARNING/padding: 3px 3px 2px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
  sed -i 's/margin: -7px -10px -4px; \/\* WARNING/margin: -7px -10px -5px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
else
  # Pango < 1.44 (original behavior, same as Pango >= 1.50)
  echo "Update %{name} for Pango < 1.44"
  sed -i 's/<border name="title_border" left="2" right="2" top="4" bottom="4"/<border name="title_border" left="2" right="2" top="4" bottom="3"/g' /usr/share/themes/human-theme/metacity-1/metacity-theme-1.xml
  sed -i 's/padding: 4px 3px 2px; \/\* WARNING/padding: 4px 3px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
  sed -i 's/padding: 3px 3px 2px; \/\* WARNING/padding: 3px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
  sed -i 's/margin: -7px -10px -5px; \/\* WARNING/margin: -7px -10px -4px; \/\* WARNING/g' /usr/share/themes/human-theme/gtk-3.0/base.css
fi


%changelog
* Tue Oct 10 2023 Fabrice Creuzot <code@luigifab.fr> - 2.1.0-1
- New upstream release

* Fri Jun 16 2023 Fabrice Creuzot <code@luigifab.fr> - 2.0.0-2
- Package spec update

* Tue Jun 06 2023 Fabrice Creuzot <code@luigifab.fr> - 2.0.0-1
- New upstream release

* Thu Sep 09 2021 Fabrice Creuzot <code@luigifab.fr> - 1.5.0-1
- New upstream release

* Wed Jul 07 2021 Fabrice Creuzot <code@luigifab.fr> - 1.4.0-1
- New upstream release

* Wed May 05 2021 Fabrice Creuzot <code@luigifab.fr> - 1.3.0-1
- New upstream release

* Sun Apr 04 2021 Fabrice Creuzot <code@luigifab.fr> - 1.2.0-1
- Initial openSUSE package release
