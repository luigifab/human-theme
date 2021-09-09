Name:          human-theme-gtk
Version:       1.5.0
Release:       1%{?dist}
Summary:       Human theme for GTK
Summary(fr):   Thème Human pour GTK
License:       GPLv3+ and LGPLv2+ and CC-BY-SA
URL:           https://github.com/luigifab/human-theme
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: hunspell-fr
Recommends:    gtk-murrine-engine
Recommends:    gnome-icon-theme
Recommends:    dmz-cursor-themes

%description %{expand:
This theme works with: GTK 2.24+ (with gtk-murrine-engine),
GTK 3.20+ (including 3.22 and 3.24), and GTK 4.0+. It is mainly
intended for MATE Desktop Environment.

After installation you must restart your session.}

%description -l fr %{expand:
Ce thème fonctionne avec : GTK 2.24+ (avec gtk-murrine-engine),
GTK 3.20+ (y compris 3.22 et 3.24), et GTK 4.0+. Il est principalement
destiné pour l'environnement de bureau Mate.

Après l'installation vous devez redémarrer votre session.}


%prep
%setup -q -n human-theme-%{version}
# Fedora use pango 1.44+
sed -i 's/<border name="title_border" left="2" right="2" top="4" bottom="3"/<border name="title_border" left="2" right="2" top="4" bottom="4"/g' src/human-theme/metacity-1/metacity-theme-1.xml
sed -i 's/padding: 4px 3px; \/\* WARNING/padding: 4px 3px 2px; \/\* WARNING/g' src/human-theme/gtk-3.0/base.css
sed -i 's/padding: 3px; \/\* WARNING/padding: 3px 3px 2px; \/\* WARNING/g' src/human-theme/gtk-3.0/base.css
sed -i 's/margin: -7px -10px -4px; \/\* WARNING/margin: -7px -10px -5px; \/\* WARNING/g' src/human-theme/gtk-3.0/base.css

%build

%install
mkdir -p %{buildroot}/etc/profile.d/
mkdir -p %{buildroot}%{_datadir}/themes/
install -p -m 644 debian/profile.sh %{buildroot}/etc/profile.d/human-theme-gtk.sh
cp -a src/human-theme/        %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-blue/   %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-green/  %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-orange/ %{buildroot}%{_datadir}/themes/

%files
%config(noreplace) /etc/profile.d/human-theme-gtk.sh
%license LICENSE
%doc README.md
# the entire source code is GPL-3+, except metacity-1/* which is LGPL-2.1+, and gtk-2.0/* which is CC-BY-SA-3.0+
%{_datadir}/themes/human-theme/
%{_datadir}/themes/human-theme-blue/
%{_datadir}/themes/human-theme-green/
%{_datadir}/themes/human-theme-orange/


%changelog
* Thu Sep 09 2021 Fabrice Creuzot <code@luigifab.fr> - 1.5.0-1
- New upstream version

* Wed Jul 07 2021 Fabrice Creuzot <code@luigifab.fr> - 1.4.0-1
- New upstream version

* Wed May 05 2021 Fabrice Creuzot <code@luigifab.fr> - 1.3.0-1
- New upstream version

* Sun Apr 04 2021 Fabrice Creuzot <code@luigifab.fr> - 1.2.0-1
- New upstream version

* Wed Nov 11 2020 Fabrice Creuzot <code@luigifab.fr> - 1.1.0-1
- Initial Fedora package release (Closes: rhbz#1893327)
