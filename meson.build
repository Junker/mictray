project('mictray', 'vala', 'c',
	version : '0.1.3',
	license : 'GPL3')

gtk_dep = dependency('gtk+-3.0', version : '>=3.22')
gee_dep = dependency('gee-0.8')
pulse_dep = dependency('libpulse')
notify_dep = dependency('libnotify')
pulse_loop_dep = dependency('libpulse-mainloop-glib')


add_project_arguments('-DGETTEXT_PACKAGE="mictray"', language: 'c')

sources = [
	'src/pulse.vala',
	'src/notification.vala',
	'src/config-file.vala',
	'src/status-icon.vala',
	'src/settings-window.vala',
	'src/dbus-server.vala'
]

install_desktoppath = join_paths(get_option('datadir'), 'applications')

install_data('mictray.desktop', install_dir: install_desktoppath)

executable('mictray', 'src/mictray.vala',
	sources,
	dependencies : [gtk_dep, pulse_dep, pulse_loop_dep, gee_dep,notify_dep],
	install: true
)
