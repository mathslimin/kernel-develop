#!/bin/bash
go mod tidy
GOOS=linux GOARCH=$1 go build -a -ldflags '-extldflags \"-static\"' -o bin/sshd_server sshd_server.go 
GOOS=linux GOARCH=$1 go build -a -ldflags '-extldflags \"-static\"' -o bin/client client.go
GOOS=linux GOARCH=$1 go build -a -ldflags '-extldflags \"-static\"' -o bin/http_server http_server.go 
