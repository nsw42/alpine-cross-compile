# https://stackoverflow.com/a/76440207/13220928 gave me the starting point for this

FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM golang:1.20.12-alpine3.18
RUN apk add clang git lld pkgconfig
COPY --from=xx / /
ARG TARGETPLATFORM
ENV CGO_ENABLED=1
RUN xx-apk add musl-dev gcc pkgconfig
RUN xx-go --wrap
