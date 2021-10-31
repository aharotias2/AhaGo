project('com.github.aharotias2.BakamonGo', 'vala', 'c', version: '0.0.1')

libm_dep = meson.get_compiler('c').find_library('libm')

gnome = import('gnome')
resources = gnome.compile_resources(
  'com.github.aharotias2.BakamonGo.resources',
  'data/com.github.aharotias2.BakamonGo.resources.xml',
  source_dir: 'data'
)

executable(
  'com.github.aharotias2.BakamonGo',
  [
    'src/bakamongo.vala',
    resources
  ],
  dependencies: [
    dependency('gdk-3.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    libm_dep
  ],
  install: true,
  install_dir: get_option('prefix') / 'bin'
)

