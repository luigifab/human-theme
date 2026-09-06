Name:          human-theme-gtk
Version:       3.3.0
Release:       %mkrel 1
Summary:       Human theme for GTK
Summary(fr):   Thème Human pour GTK
License:       GPLv3+ and LGPLv2+ and CC-BY-SA
Group:         Graphical desktop/MATE
URL:           https://github.com/luigifab/human-theme
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: aspell-fr
Recommends:    mate-icon-theme
Recommends:    cursor-theme-dmz
Recommends:    gtk-murrine-engine
Recommends:    gtk-pixbuf-engine
#ecommends:    qt5-gtk-platformtheme ?
Recommends:    qt5-globalqss
Recommends:    qtsvg5
#ecommends:    qt6-gtk-platformtheme ?
Recommends:    qt6-globalqss
Recommends:    qtsvg6

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
%setup -n human-theme-%{version}
sed -i 's/IconTheme=gnome/IconTheme=mate/g' src/*/index.theme
sed -i 's/gnome/mate/g' src/*/firefox/firefox.css

%install
install -dm 755 %{buildroot}%{_datadir}/themes/
cp -a src/Human/                 %{buildroot}%{_datadir}/themes/
cp -a src/Human-blue/            %{buildroot}%{_datadir}/themes/
cp -a src/Human-green/           %{buildroot}%{_datadir}/themes/
cp -a src/Human-orange/          %{buildroot}%{_datadir}/themes/
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
* Fri Jan 01 2027 Fabrice Creuzot <code@luigifab.fr> - 3.3.0-1pclos2027
- New upstream release

* Tue Jul 07 2026 Fabrice Creuzot <code@luigifab.fr> - 3.2.0-1pclos2026
- New upstream release

* Tue May 05 2026 Fabrice Creuzot <code@luigifab.fr> - 3.1.0-1pclos2026
- New upstream release

* Sun Aug 10 2025 tex - 2.6.0-1pclos2025
- Initial PCLinuxOS package release










































