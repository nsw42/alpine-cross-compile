# Cross-compiling go + gtk4 for Raspberry Pi

## Background

This repository supports GTK-based golang applications for the Raspberry Pi. Building the go gtk4 bindings (from <https://github.com/diamondburned/gotk4>) ended up using more RAM than my Pi's 1GB. This set of Docker images builds on <https://github.com/tonistiigi/xx> to cross-compile from a host machine (in my case, my MacBook Pro) to the Pi.

It supports both 32-bit (`armhf`) and 64-bit (`arm64`) ARM builds. It should be possible to get other platforms to work too, with some minor tweaks.

## Prerequisites

Stating the obvious, you'll need [Docker](https://www.docker.com/products/docker-desktop/).

## Supported CPUs/OSs

Out-of-the-box, the currently supported platforms are `linux/armhf` and `linux/arm64` on Alpine Linux and Debian. The system is designed to be flexible, so other OSs are supported by following the detailed instructions. (Send a PR to incorporate the support into the mainline?)

## Simple approach

If you just want to build an application that relies on these Docker images, then invoke the build script specifying your platform (i.e. CPU and OS combination):

```sh
cd alpine-cross-compile
./build.sh CPU OS
```

where:

* CPU is either `armhf` or `arm64`
* OS is one of `alpine3.19` or `bookworm`

If you don't specify a platform, it will build for all four combinations of (`linux/armhf`,`linux/arm64`)x(Alpine 3.19,Debian Bookworm) platforms.

Expect this to take a while: building the GTK4 bindings takes 15-20 minutes per-platform on an M1 Max MacBook Pro.

(Other versions of Alpine - e.g. `alpine3.18` or `alpine3.20` - should work, as should newer Debian releases, provided that the base image exists in <https://hub.docker.com/_/golang>. However, note that Bullseye (Debian 11) does not include gtk4 as an installable package, and so would require much more effort to get working.)

Docker images `go-cross-builder-OS-CPU` and `gotk-cross-builder-OS-CPU` will be created.

## Detailed instructions

If the simple approach doesn't work for you - e.g. because you want to build an unsupported combination of CPU and OS - then it's probably possible, by passing additional arguments to the build script.

```sh
cd alpine-cross-compile
./build.sh PLATFORM OSNAME GOLANGBASEIMAGE TAGSUFFIX
```

where:

* PLATFORM is the platform name as Docker recognises it (e.g. `linux/armhf`)
* OSNAME is such that builder-image/OSNAME_setup.sh exists (e.g. `alpine`)
* GOLANGBASEIMAGE is one of the golang base images, e.g. golang:1.22.0-alpine3.19
* TAGSUFFIX is a string to append to cross-builder image tags. It can be anything at all, but using a different tag suffix for different combinations of CPU/OS enables multiple cross-builder images to be installed at the same time.

Docker images `go-cross-builder-TAGSUFFIX` and `gotk-cross-builder-TAGSUFFIX` will be created.

## Using the Docker images

The image containing the gotk libraries is probably the image you want to use. There is a shell script in the Debian image that sets up the environment for cross-compiling, and you may need to explicitly include that in your scripts.

So, a typical usage is to have a build script that reads that environment script if it exists (because it's not needed for Alpine Linux), and then perform a go build as normal:

```sh
#! /bin/sh
[ -f /etc/profile.d/go_cross.sh ] && . /etc/profile.d/go_cross.sh

go mod tidy
go build .
```

The Docker command-line to perform the build is then:

```sh
docker run -it --rm -v .:/go/src -w /go/src gotk-cross-builder-bookworm-arm64 ./build.sh
```

(changing `gotk-cross-builder-bookworm-arm64` for whichever particular platform you want to build for)

## Notes for developers

This repo contains two directories: one that's a generic cross-builder, and one that incorporates the GTK bindings.

1. `builder-image`
    * This is just a thin veneer over tonistiigi's xx to tailor it to the specific OS, and to install some basic OS-level packages.
    * Usage:

      ```sh
      cd builder-image
      docker build --platform $PLATFORM --build-arg OSNAME=$OSNAME --build-arg BASE_IMAGE=$BASE_IMAGE -t $CROSS_BUILDER_TAG .
      ```

      The file `OSNAME_setup.sh` must exist in the `builder-image` directory; currently, alpine and debian exist.

    * There's also a 'hello world' in this directory, to allow you to check that cross-compiling is working after you've built the Docker image:

      ```sh
      cd builder-image/hello
      docker run -it --rm -v ./:/go/src -w /go/src $CROSS_BUILDER_TAG go build -o hello hello.go
      ```

      then scp the resulting binary (`hello`) to the target platform, run it and check it prints `Hello world`.

2. `gtk-image`
    * This installs the GTK4 libraries (and prerequisites) and builds the `gotk4` bindings
    * There are significant differences between the Alpine and Debian build steps, and there are therefore different Dockerfiles for the different operating systems.
    * Usage:

      ```sh
      cd gtk-image
      docker build --platform $PLATFORM --build-arg CROSS_BUILDER=$CROSS_BUILDER_TAG -t $GTK_BUILDER_TAG -f Dockerfile_OSNAME .
      ```

    * This directory also contains a hello world, demonstrating the go/GTK4 bindings:

      ```sh
      cd gtk-image/gtkdemo
      docker run -it --rm -v ./:/go/src -w /go/src -e HOST=macOS $GTK_BUILDER_TAG ./build.sh
      ```

## References

As well as the repositories referenced above, the following sources proved useful along the way:

* <https://stackoverflow.com/a/76440207/13220928>
* <https://medium.com/@tonistiigi/faster-multi-platform-builds-dockerfile-cross-compilation-guide-part-1-ec087c719eaf>
