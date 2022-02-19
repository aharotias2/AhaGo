project('com.github.aharotias2.AhaGo', 'vala', 'c', version: '0.0.1')

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
    'src/aha-consts.vala',
    'src/enum/aha-go-tern.vala',
    'src/enum/aha-go-status.vala',
    'src/enum/aha-model-size.vala',
    'src/misc/aha-label-builder.vala',
    'src/model/aha-go-model.vala',
    'src/model/aha-history-item.vala',
    'src/widgethelper/aha-ball-drawer.vala',
    'src/widgethelper/aha-dpoint.vala',
    'src/widget/aha-mini-go-widget.vala',
    'src/widget/aha-go-pows-widget.vala',
    'src/widget/aha-go-widget.vala',
    'src/widget/aha-go-score-board.vala',
    'src/widget/aha-title-logo.vala',
    'src/widget/aha-tern-switcher.vala',
    'src/widget/aha-stopwatch.vala',
    'src/aha-go.vala',
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

foreach size : ['16', '24', '32', '48', '128']
  install_data(
    'data/icons/@0@/@1@.png'.format(size, meson.project_name()),
    install_dir: get_option('datadir') / 'icons/hicolor/@0@x@0@/apps'.format(size)
  )
endforeach

install_data(
  'data/@0@.desktop'.format(meson.project_name()),
  install_dir: get_option('datadir') / 'applications'
)

meson.add_install_script('meson/post_install.py')
