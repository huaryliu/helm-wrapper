BINARY_NAME=helm-wrapper

GOPATH = $(shell go env GOPATH)

LDFLAGS="-s -w"

build:
	go build -ldflags ${LDFLAGS} -o bin/${BINARY_NAME} 

# cross compilation
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags ${LDFLAGS} -o bin/${BINARY_NAME}

build-windows:
	CGO_ENABLED=0 GOOS=windows GOARCH=386 go build -ldflags ${LDFLAGS} -o bin/${BINARY_NAME}

# build docker image
build-docker:
	rm -rf bin/${BINARY_NAME}
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags ${LDFLAGS} -o bin/${BINARY_NAME}
	docker build -t helm-wrapper:`git rev-parse --short HEAD` .

.PHONY: golangci-lint
golangci-lint: $(GOLANGCILINT)
	@echo
	$(GOPATH)/bin/golangci-lint run

$(GOLANGCILINT):
	(cd /; GO111MODULE=on GOPROXY="direct" GOSUMDB=off go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.30.0)
