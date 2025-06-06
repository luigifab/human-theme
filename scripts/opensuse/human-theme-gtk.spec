Name:          human-theme-gtk
Version:       2.5.0
Release:       0
Summary:       Human theme for GTK
Summary(fr):   Thème Human pour GTK
License:       GPL-3.0-or-later and LGPL-2.1-or-later and CC-BY-SA-3.0
URL:           https://github.com/luigifab/human-theme
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: aspell-fr
Recommends:    dmz-icon-theme-cursors
Recommends:    gnome-icon-theme
Recommends:    gtk2-engine-murrine
# https://software.opensuse.org/search?baseproject=openSUSE%3AFactory&q=qt+theme+gtk
Suggests:      libqt5-qtbase-platformtheme-gtk3
Suggests:      libqt5-qtstyleplugins-platformtheme-gtk2
Suggests:      qt6-platformtheme-gtk3

%description %{expand:
This theme works with GTK 2.24 (with gtk2-engine-murrine), 3.24, and 4.12.
Better rendering with Pango 1.42- or 1.51+.

It is mainly intended for MATE and Xfce desktop environments.
After installation you must restart your session.}

%description -l fr %{expand:
Ce thème fonctionne avec : GTK 2.24 (avec gtk2-engine-murrine), 3.24, et 4.12.
Meilleur rendu avec Pango 1.42- ou 1.51+.

Il est principalement destiné pour les environnements de bureau MATE et Xfce.
Après l'installation vous devez redémarrer votre session.}


%prep
%setup -q -n human-theme-%{version}
sed -i 's/IconTheme=gnome/IconTheme=mate/g' src/*/index.theme

%install
install -dm 755 %{buildroot}%{_datadir}/themes/
cp -a src/human-theme/           %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-blue/      %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-green/     %{buildroot}%{_datadir}/themes/
cp -a src/human-theme-orange/    %{buildroot}%{_datadir}/themes/
install -Dpm 644 data/profile.sh %{buildroot}%{_sysconfdir}/profile.d/%{name}.sh

%files
%config(noreplace) %{_sysconfdir}/profile.d/%{name}.sh
%license LICENSE
%doc README.md
# the entire source code is GPL-3.0-or-later, except */metacity-1/* which is LGPL-2.1-or-later,
# and */gtk-2.0/* which is CC-BY-SA-3.0-or-later
%{_datadir}/themes/human-theme/
%{_datadir}/themes/human-theme-blue/
%{_datadir}/themes/human-theme-green/
%{_datadir}/themes/human-theme-orange/


%changelog
* Fri Jun 06 2025 Fabrice Creuzot <code@luigifab.fr> - 2.5.0-1
- New upstream release

* Mon May 05 2025 Fabrice Creuzot <code@luigifab.fr> - 2.4.0-1
- New upstream release

* Fri Apr 04 2025 Fabrice Creuzot <code@luigifab.fr> - 2.3.0-1
- New upstream release

* Mon Mar 03 2025 Fabrice Creuzot <code@luigifab.fr> - 2.2.1-1
- New upstream release

* Fri Feb 02 2024 Fabrice Creuzot <code@luigifab.fr> - 2.2.0-1
- New upstream release

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



