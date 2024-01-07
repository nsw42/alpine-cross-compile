FROM --platform=$BUILDPLATFORM go-cross-builder-image
ARG TARGETPLATFORM
RUN xx-apk add gtk4.0 gtk4.0-dev
RUN xx-apk add gobject-introspection-dev
RUN xx-apk add shared-mime-info
ADD gtk-image-lib-builder /go/gtk-image-lib-builder
# TODO: It'd be good to etxract the prefix from xx
ENV PKG_CONFIG_PATH=/armv7-alpine-linux-musleabihf/usr/share/pkgconfig
RUN cd /go/gtk-image-lib-builder; go build -v -x .
