#! /bin/sh

go mod tidy
# Use `docker run ... -e HOST=yourHostPlatformOrName ...`
go build -ldflags "-X main.hostPlatform=$HOST" -o gtkdemo gtkdemo.go
