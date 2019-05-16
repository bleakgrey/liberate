project('liberate', 'vala', 'c', meson_version: '>= 0.48.2', version: '1.0')

gnome = import('gnome')
i18n = import('i18n')
pkgconfig = import('pkgconfig')

add_global_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

lib_deps = [
    dependency('webkit2gtk-4.0')
]

subdir('lib')
subdir('demo')
