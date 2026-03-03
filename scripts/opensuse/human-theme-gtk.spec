Name:          human-theme-gtk
Version:       3.0.0
Release:       0
Summary:       Human theme for GTK
Summary(fr):   Thème Human pour GTK
License:       GPL-3.0-or-later and LGPL-2.1-or-later and CC-BY-SA-3.0
URL:           https://github.com/luigifab/human-theme
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: aspell-fr
Recommends:    gnome-icon-theme
Recommends:    dmz-icon-theme-cursors
Recommends:    gtk2-engine-murrine
Recommends:    libqt5-qtbase-platformtheme-gtk3
Recommends:    libqt5-qtsvg
Recommends:    qt5-globalqss
Recommends:    qt6-platformtheme-gtk3
Recommends:    qt6-globalqss
Recommends:    qt6-svg


%description %{expand:
This theme is mainly intended for MATE and Xfce desktop environments.

After installation you must restart your session.
After uninstallation be sure to remove the config file:
 /etc/profile.d/human-theme-gtk.sh}

%description -l fr %{expand:
Ce thème est principalement destiné pour les environnements
de bureau MATE et Xfce.

Après l'installation vous devez redémarrer votre session.
Après la désinstallation, veillez à supprimer le fichier de config :
 /etc/profile.d/human-theme-gtk.sh}


%prep
%setup -q -n human-theme-%{version}
sed -i 's/IconTheme=gnome/IconTheme=mate/g' src/*/index.theme

%install
install -dm 755 %{buildroot}%{_datadir}/themes/
cp -a src/Human/           %{buildroot}%{_datadir}/themes/
cp -a src/Human-blue/      %{buildroot}%{_datadir}/themes/
cp -a src/Human-green/     %{buildroot}%{_datadir}/themes/
cp -a src/Human-orange/    %{buildroot}%{_datadir}/themes/
install -Dpm 644 data/profile.sh %{buildroot}%{_sysconfdir}/profile.d/%{name}.sh

%files
%config(noreplace) %{_sysconfdir}/profile.d/%{name}.sh
%license LICENSE
%doc README.md
# the entire source code is GPL-3.0-or-later, except */metacity-1/* which is LGPL-2.1-or-later,
# and */gtk-2.0/* which is CC-BY-SA-3.0-or-later
%{_datadir}/themes/Human/
%{_datadir}/themes/Human-blue/
%{_datadir}/themes/Human-green/
%{_datadir}/themes/Human-orange/


%changelog
* Tue Mar 03 2026 Fabrice Creuzot <code@luigifab.fr> - 3.0.0-1
- New upstream release

* Fri Aug 08 2025 Fabrice Creuzot <code@luigifab.fr> - 2.6.0-1
- New upstream release

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



