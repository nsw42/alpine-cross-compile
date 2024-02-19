# https://stackoverflow.com/a/76440207/13220928 gave me the starting point for this

ARG BASE_IMAGE=golang:latest

FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}
COPY --from=xx / /
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM}
ENV CGO_ENABLED=1
ARG OSNAME
COPY --chmod=777 ${OSNAME}_setup.sh /usr/local/bin/os_setup_builder_image.sh
RUN /usr/local/bin/os_setup_builder_image.sh
RUN xx-go --wrap
