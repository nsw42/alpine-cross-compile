# Cross-compiling go + gtk4 for a 32-bit (ARMv7) Raspberry Pi / Alpine Linux

## Background

This repository supports <https://github.com/nsw42/piju-touchscreen-go>, a UI for a custom music player, which is written in go. Building the go gtk4 bindings (from <https://github.com/diamondburned/gotk4>) ended up using more RAM than my Pi's 1GB. This set of Docker images builds on <https://github.com/tonistiigi/xx> to cross-compile from a host machine (in my case, my MacBook Pro) to the Pi.

## Prerequisites

Stating the obvious, you'll need [Docker](https://www.docker.com/products/docker-desktop/).

## Contents

This repo contains two directories:

1. `builder-image`
    * This is just a thin veneer over tonistiigi's xx to tailor it to specific Alpine versions, and to install some basic OS-level packages.
    * Usage:

      ```sh
      $ cd builder-image
      $ docker build --platform linux/armhf -t go-cross-builder-image .
      ```

    * There's also a 'hello world' in this directory, to allow you to check that cross-compiling is working after you've built the Docker image:

      ```sh
      $ docker run -it --rm -v ./:/go/src -w /go/src go-cross-builder-image go build -o hello hello.go
      ```
      
      then scp the resulting binary (`hello`) to the target platform, run it and check it prints `Hello world`.
      
2. `gtk-image`
    * This installs the GTK4 libraries (and prerequisites) and builds the `gotk4` bindings
    * Usage:

      ```sh
      $ cd gtk-image
      $ docker build --platform linux/armhf -t go-gtk-image .
      ```

    * This directory also contains a hello world, demonstrating the go/GTK4 bindings:

      ```sh
      $ cd gtkdemo
      $ docker run -it --rm -v ./:/go/src -w /go/src -e HOST=macOS go-gtk-image ./build.sh
      ```

## References

As well as the repositories referenced above, the following sources proved useful along the way:

* <https://stackoverflow.com/a/76440207/13220928>
* <https://medium.com/@tonistiigi/faster-multi-platform-builds-dockerfile-cross-compilation-guide-part-1-ec087c719eaf>
 
