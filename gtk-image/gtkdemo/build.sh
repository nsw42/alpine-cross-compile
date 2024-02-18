#! /bin/sh

[ -f /etc/profile.d/gotk_cross.sh ] && . /etc/profile.d/gotk_cross.sh

go mod tidy
# Use `docker run ... -e HOST=yourHostPlatformOrName ...`
go build -ldflags "-X main.hostPlatform=$HOST" -o /go/output/gtkdemo -v gtkdemo.go

xx-verify /go/output/gtkdemo
