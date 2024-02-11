# Cross-compiling go + gtk4 for Raspberry Pi

## Background

This repository supports GTK-based golang applications for the Raspberry Pi. Building the go gtk4 bindings (from <https://github.com/diamondburned/gotk4>) ended up using more RAM than my Pi's 1GB. This set of Docker images builds on <https://github.com/tonistiigi/xx> to cross-compile from a host machine (in my case, my MacBook Pro) to the Pi.

It supports both 32-bit (`armhf`) and 64-bit (`arm64`) ARM builds. It should be possible to get other platforms to work too, with a minor tweak to gtk-image/Dockerfile.

## Prerequisites

Stating the obvious, you'll need [Docker](https://www.docker.com/products/docker-desktop/).

## Simple approach

If you just want to build these Docker images to build an application that relies on these Docker images:

```
cd alpine-cross-compile
./build_both.sh PLATFORM
```

where PLATFORM is either `linux/armhf` or `linux/arm64`.

If you don't specify a platform, it will build for both platforms. 

Expect this to take a while: building the GTK4 bindings takes 15-20 minutes per-platform on an M1 Max MacBook Pro.

## Detailed instructions

If you are only building for a single platform, figure out which one (`linux/armhf` or `linux/arm64`) you're building for. `$PLATFORM` is used throughout the instructions below to refer to the appropriate value.

This repo contains two directories: one that's a generic cross-builder, and one that incorporates the GTK bindings. The second refers to the first, so you need to tag the first. The instructions below use `$CROSS_BUILDER_TAG` to refer to that; as an example, the `build_both.sh` script uses `go-cross-builder-image-linuxarmhf` and `go-cross-builder-image-linuxarm64`. Avoid spaces and slash characters in the tag.

You'll likely want to tag the second, too, so you can refer to it when building your application. The instructions below use `$GTK_BUILDER_TAG` for that. The `build_both.sh` script uses `go-gtk-image-linuxarmhf` and `go-gtk-image-linuxarm64`. Again, avoid spaces and slashes.

1. `builder-image`
    * This is just a thin veneer over tonistiigi's xx to tailor it to specific Alpine versions, and to install some basic OS-level packages.
    * Usage:

      ```sh
      $ cd builder-image
      $ docker build --platform $PLATFORM -t $CROSS_BUILDER_TAG .
      ```

    * There's also a 'hello world' in this directory, to allow you to check that cross-compiling is working after you've built the Docker image:

      ```sh
      $ docker run -it --rm -v ./:/go/src -w /go/src $CROSS_BUILDER_TAG go build -o hello hello.go
      ```

      then scp the resulting binary (`hello`) to the target platform, run it and check it prints `Hello world`.

2. `gtk-image`
    * This installs the GTK4 libraries (and prerequisites) and builds the `gotk4` bindings
    * Usage:

      ```sh
      $ cd gtk-image
      $ docker build --platform $PLATFORM --build-arg CROSSBUILDER=$CROSS_BUILDER_TAG -t $GTK_BUILDER_TAG .
      ```

    * This directory also contains a hello world, demonstrating the go/GTK4 bindings:

      ```sh
      $ cd gtkdemo
      $ docker run -it --rm -v ./:/go/src -w /go/src -e HOST=macOS $GTK_BUILDER_TAG ./build.sh
      ```

## References

As well as the repositories referenced above, the following sources proved useful along the way:

* <https://stackoverflow.com/a/76440207/13220928>
* <https://medium.com/@tonistiigi/faster-multi-platform-builds-dockerfile-cross-compilation-guide-part-1-ec087c719eaf>
 
