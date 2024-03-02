#! /bin/sh

set -e

GOLANG_VERSION=1.22.0

build_platform() {
  PLATFORM=$1    # eg linux/armhf
  OSNAME=$2      # eg alpine or debian
  BASE_IMAGE=$3  # e.g. golang:1.22.0-alpine3.19
  TAGSUFFIX=$4   # can be anything, but e.g. alpine3.19-armhf

  echo ================================================================================================================
  echo "Building $TAGSUFFIX ($PLATFORM $OSNAME $BASE_IMAGE)"

  CROSS_BUILDER_TAG=go-cross-builder-$TAGSUFFIX
  GOTK_BUILDER_TAG=gotk-cross-builder-$TAGSUFFIX

  # Step 1: Build the builder image
  pushd builder-image > /dev/null
  if [ ! -f cyclonedx-gomod ]; then
    if [ "$(arch)" = "arm64" ]; then
      DOWNLOAD_ARCH=arm64
    else
      DOWNLOAD_ARCH=amd64
    fi
    curl -LO https://github.com/CycloneDX/cyclonedx-gomod/releases/download/v1.6.0/cyclonedx-gomod_1.6.0_linux_${DOWNLOAD_ARCH}.tar.gz
    tar xf cyclonedx-gomod_1.6.0_linux_${DOWNLOAD_ARCH}.tar.gz cyclonedx-gomod
  fi
  docker build --platform $PLATFORM --build-arg OSNAME="$OSNAME" --build-arg BASE_IMAGE="$BASE_IMAGE" -t "$CROSS_BUILDER_TAG" .
  popd > /dev/null

  # Step 2: Build the hello world application to demonstrate the builder image
  pushd builder-image/hello > /dev/null
  docker run -it --rm -v ./:/go/src -v ./build/$TAGSUFFIX:/go/output -w /go/src "$CROSS_BUILDER_TAG" ./build.sh
  popd > /dev/null

  # Step 3: Use the builder image to build the GTK libraries
  pushd gtk-image > /dev/null
  docker build --platform $PLATFORM --build-arg CROSS_BUILDER="$CROSS_BUILDER_TAG" -t "$GOTK_BUILDER_TAG" -f Dockerfile_$OSNAME .
  popd > /dev/null

  # Step 4: Use the GTK libraries to build the example application
  pushd gtk-image/gtkdemo > /dev/null
  CPU=${PLATFORM##*/}
  docker run -it --rm -v ./:/go/src -v ./build/$TAGSUFFIX:/go/output -w /go/src -e HOST="$(hostname)-$(uname)" "$GOTK_BUILDER_TAG" ./build.sh
  popd > /dev/null
}

build_platform_with_default_go() {
  build_platform "$1" "$2" "golang:$GOLANG_VERSION-$3" "$4"
}

if [ "$#" -eq 0 ]; then
  for CPU in armhf arm64; do
    build_platform_with_default_go  linux/$CPU  alpine  alpine3.19  alpine3.19-$CPU
    build_platform_with_default_go  linux/$CPU  debian  bookworm    bookworm-$CPU
  done
elif [ "$#" -eq 2 ]; then
  CPU=$1
  OSVERSION=$2
  if [[ $OSVERSION = alpine* ]]; then
    OSNAME=alpine
  else
    OSNAME=debian
  fi
  build_platform_with_default_go  linux/$CPU  $OSNAME  $OSVERSION   $OSVERSION-$CPU
elif [ "$#" -eq 4 ]; then
  build_platform "$@"
else
  SCRIPT=$(basename $0)
  echo "Usage: $SCRIPT  CPUTYPE  OSVERSION"
  echo "  CPUTYPE is armhf or arm64"
  echo "  OSVERSION is something like alpine3.19 - the Docker image golang:$GOLANG_VERSION-OSVERSION must exist"
  echo "  The script will try to figure out whether the given OS version is an Alpine Linux or Debian image"
  echo ""
  echo "Usage: $SCRIPT PLATFORM OSNAME GOLANGBASEIMAGE TAGSUFFIX"
  echo "  PLATFORM is something like linux/armhf"
  echo "  OSNAME is alpine or debian - this serves as an extension point if you are adding support for another OS"
  echo "  GOLANGBASEIMAGE is one of the golang base images, e.g. golang:$GOLANG_VERSION-alpine3.19"
  echo "  TAGSUFFIX is a string to append to cross-builder image tags, for uniqueness"
  exit 1
fi
