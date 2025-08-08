Name:          human-theme-gtk
Version:       2.6.0
Release:       1
Summary:       Human theme for GTK
Summary(fr):   Thème Human pour GTK
License:       GPL-3.0-or-later and LGPL-2.1-or-later and CC-BY-SA-3.0
Group:         Graphical desktop/MATE
URL:           https://github.com/luigifab/human-theme
Source0:       %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:     noarch
BuildRequires: aspell-fr
Recommends:    dmz-cursor-themes
Recommends:    mate-icon-theme
Recommends:    murrine




%description %{expand:
This theme works with GTK 2.24 (with murrine), 3.24, and 4.12.
Better rendering with Pango 1.42- or 1.51+.

It is mainly intended for MATE and Xfce desktop environments.
After installation you must restart your session.}

%description -l fr %{expand:
Ce thème fonctionne avec : GTK 2.24 (avec murrine), 3.24, et 4.12.
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
* Fri Aug 08 2025 Fabrice Creuzot <code@luigifab.fr> - 2.6.0-1
- New upstream release

* Fri Jun 06 2025 Fabrice Creuzot <code@luigifab.fr> - 2.5.0-1
- New upstream release

* Mon May 05 2025 Fabrice Creuzot <code@luigifab.fr> - 2.4.0-1
- New upstream release

* Fri Apr 04 2025 Fabrice Creuzot <code@luigifab.fr> - 2.3.0-1
- Initial OpenMandriva package release (Closes: #3165)






























