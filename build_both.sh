#! /bin/sh

set -x

build_both() {
  PLATFORM=$1
  TAGSUFFIX=$(echo "$PLATFORM" | sed 's:/::')
  CROSS_BUILDER_TAG="go-cross-builder-image-$TAGSUFFIX"

  pushd builder-image 2> /dev/null
  docker build --platform $PLATFORM -t "$CROSS_BUILDER_TAG" .
  popd 2> /dev/null

  pushd gtk-image 2> /dev/null
  docker build --platform $PLATFORM --build-arg CROSSBUILDER="$CROSS_BUILDER_TAG" -t "go-gtk-image-$TAGSUFFIX" .
  popd 2> /dev/null
}

if [ "$#" -eq 0 ]; then
  build_both linux/armhf
  build_both linux/arm64
else
  for platform; do
    build_both "$platform"
  done
fi
