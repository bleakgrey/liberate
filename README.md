# liberate
Reader mode for libwebkit2gtk

## Building and Installation
You'll need the following dependencies:
* meson >= 0.48.2
* valac
* webkit2gtk-4.0

Run these commands to build liberate:

  meson build --prefix=/usr
  cd build
  ninja

This command creates a `build` directory. For all following commands, change to
the build directory before running them.

To install, run `ninja install`:

    ninja install

To uninstall, run `ninja uninstall`:

    ninja uninstall

To see a demo app, run `liberate-demo` after installing liberate:

    liberate-demo
