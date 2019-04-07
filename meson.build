project('mictray', 'vala', 'c',
	version : '0.1.0',
	license : 'GPL3')

gtk_dep = dependency('gtk+-3.0', version : '>=3.22')
gee_dep = dependency('gee-0.8')
pulse_dep = dependency('libpulse')
pulse_loop_dep = dependency('libpulse-mainloop-glib')


add_project_arguments('-DGETTEXT_PACKAGE="mictray"', language: 'c')

sources = [
	'src/pulse.vala',
	'src/config-file.vala',
	'src/status-icon.vala',
	'src/settings-window.vala'
]

executable('mictray', 'src/mictray.vala',
	sources,
	dependencies : [gtk_dep, pulse_dep, pulse_loop_dep, gee_dep],
	install: true
)
