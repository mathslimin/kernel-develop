#!/bin/bash
go mod tidy
GOOS=linux GOARCH=$1 go build -a -ldflags '-extldflags \"-static\"' sshd_server.go
GOOS=linux GOARCH=$1 go build -a -ldflags '-extldflags \"-static\"' client.go
