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
    'src/bakamonconsts.vala',
    'src/enum/bakamongotern.vala',
    'src/enum/bakamongostatus.vala',
    'src/enum/bakamonmodelsize.vala',
    'src/misc/bakamonlabelbuilder.vala',
    'src/model/bakamongomodel.vala',
    'src/model/bakamonhistoryitem.vala',
    'src/widgethelper/bakamonballdrawer.vala',
    'src/widgethelper/bakamondpoint.vala',
    'src/widget/bakamonminigowidget.vala',
    'src/widget/bakamongopowswidget.vala',
    'src/widget/bakamongowidget.vala',
    'src/widget/bakamongoscoreboard.vala',
    'src/widget/bakamontitlelogo.vala',
    'src/widget/bakamonternswitcher.vala',
    'src/widget/bakamonstopwatch.vala',
    'src/bakamongo.vala',
    resources
  ],
  dependencies: [
    dependency('glib-2.0'),
    dependency('gdk-3.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    libm_dep
  ],
  install: true,
  install_dir: get_option('prefix') / 'bin'
)

install_data(
  'data/com.github.aharotias2.BakamonGo.png',
  install_dir: get_option('datadir') / 'share/icons/hicolor/128x128/apps'
)

install_data(
  'data/com.github.aharotias2.BakamonGo.desktop',
  install_dir: get_option('datadir') / 'applications'
)

