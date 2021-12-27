project('com.github.aharotias2.BakamonGo', 'vala', 'c', version: '0.0.1')

libm_dep = meson.get_compiler('c').find_library('libm')

gnome = import('gnome')
resources = gnome.compile_resources(
  '@0@.resources'.format(meson.project_name()),
  'data/@0@.resources.xml'.format(meson.project_name()),
  source_dir: 'data'
)

add_project_arguments(
  [
    '--vapidir', meson.current_source_dir() / 'vapi',
    '--pkg', 'config'
  ],
  language: 'vala'
)

config_h = configuration_data()
config_h.set_quoted('VERSION', meson.project_version())
config_h.set_quoted('APP_ID', meson.project_name())
config_h.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))

config_file = configure_file(
  output: 'config.h',
  configuration: config_h
)

project_config_dep = declare_dependency(
  sources: config_file,
  include_directories: include_directories('.')
)

executable(
  meson.project_name(),
  [
    'src/bakamon-consts.vala',
    'src/enum/bakamon-go-tern.vala',
    'src/enum/bakamon-go-status.vala',
    'src/enum/bakamon-model-size.vala',
    'src/misc/bakamon-label-builder.vala',
    'src/model/bakamon-go-model.vala',
    'src/model/bakamon-history-item.vala',
    'src/widgethelper/bakamon-ball-drawer.vala',
    'src/widgethelper/bakamon-dpoint.vala',
    'src/widget/bakamon-mini-go-widget.vala',
    'src/widget/bakamon-go-pows-widget.vala',
    'src/widget/bakamon-go-widget.vala',
    'src/widget/bakamon-go-score-board.vala',
    'src/widget/bakamon-title-logo.vala',
    'src/widget/bakamon-tern-switcher.vala',
    'src/widget/bakamon-stopwatch.vala',
    'src/bakamon-go.vala',
    resources
  ],
  dependencies: [
    dependency('glib-2.0'),
    dependency('gdk-3.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    libm_dep,
    project_config_dep
  ],
  install: true,
  install_dir: get_option('prefix') / 'bin'
)

install_data(
  'data/@0@.png'.format(meson.project_name()),
  install_dir: get_option('datadir') / 'share/icons/hicolor/128x128/apps'
)

install_data(
  'data/@0@.desktop'.format(meson.project_name()),
  install_dir: get_option('datadir') / 'applications'
)

