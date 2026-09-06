#!/usr/bin/python
# Copyright 2020-2027 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
# https://github.com/luigifab/human-theme
#
# Forked from
#  Copyright 2020 | Mike Kazantsev (mk-fg) <mk~fraggod~gmail~com>
#  https://github.com/mk-fg/clearlooks-phenix-humanity
#
# Forked from
#  Copyright 2011-2014 | Jean-Philippe Fleury
#  Copyright 2013-2014 | Andrew Shadura
#  https://github.com/jpfleury/clearlooks-phenix
#
# This program is free software, you can redistribute it or modify
# it under the terms of the GNU General Public License (GPL) as published
# by the free software foundation, either version 3 of the license, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but without any warranty, without even the implied warranty of
# merchantability or fitness for a particular purpose. See the
# GNU General Public License (GPL) for more details.

import gi, sys, argparse
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class TestApp(Gtk.Application):

	def __init__(self, colors):
		super().__init__()
		self.colors = colors

	def do_activate(self):
		win = Gtk.ApplicationWindow(name='test', application=self)
		screen  = win.get_screen()
		context = win.get_style_context()

		for i, spec in enumerate(self.colors):
			name = f'test-40f4o-{i}'
			provider = Gtk.CssProvider()
			provider.load_from_data(f'@define-color {name} {spec};'.encode())
			Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
			color = context.lookup_color(name)
			assert color[0], f'Color not found: {spec}'
			r, g, b, a = (round(c * 255) for c in color[1])
			color_str = f'#{r:02x}{g:02x}{b:02x}'
			if a != 255:
				color_str += f'{a:02x}'
			print(color_str.upper())

		self.quit()

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='Translate specified color via GTK3 CSS system to #RRGGBB[AA] value.')
	parser.add_argument('color', nargs='+', help='GTK3 color specification. Can include any color expressions or theme color refs.')
	parser.add_argument('--theme', help='Theme name.', default=None)
	opts = parser.parse_args()
	if opts.theme:
		settings = Gtk.Settings.get_default()
		if settings:
			settings.set_property('gtk-theme-name', opts.theme)
	sys.exit(TestApp(opts.color).run())
