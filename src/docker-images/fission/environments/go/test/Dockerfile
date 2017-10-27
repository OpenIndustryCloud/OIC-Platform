FROM node:8-alpine

# First we convert this image and add Go
RUN apk add --no-cache ca-certificates

ENV GOLANG_VERSION 1.8.4
ENV FUNCTION_PATH="./"

# https://golang.org/issue/14851 (Go 1.8 & 1.7)
# https://golang.org/issue/17847 (Go 1.7)
COPY test/*.patch /go-alpine-patches/

RUN set -eux; \
  apk add --no-cache --virtual .build-deps \
    bash \
    gcc \
    musl-dev \
    openssl \
    go \
    curl \
    jq \
    git \
  ; \
  export \
# set GOROOT_BOOTSTRAP such that we can actually build Go
    GOROOT_BOOTSTRAP="$(go env GOROOT)" \
# ... and set "cross-building" related vars to the installed system's values so that we create a build targeting the proper arch
# (for example, if our build host is GOARCH=amd64, but our build env/image is GOARCH=386, our build needs GOARCH=386)
    GOOS="$(go env GOOS)" \
    GOARCH="$(go env GOARCH)" \
    GO386="$(go env GO386)" \
    GOARM="$(go env GOARM)" \
    GOHOSTOS="$(go env GOHOSTOS)" \
    GOHOSTARCH="$(go env GOHOSTARCH)" \
  ; \
  \
  wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
  echo 'abf1b2e5ae2a4845f3d2eac00c7382ff209e2c132dc35b7ce753da9b4f52e59f *go.tgz' | sha256sum -c -; \
  tar -C /usr/local -xzf go.tgz; \
  rm go.tgz; \
  \
  cd /usr/local/go/src; \
  for p in /go-alpine-patches/*.patch; do \
    [ -f "$p" ] || continue; \
    patch -p2 -i "$p"; \
  done; \
  ./make.bash; \
  \
  rm -rf /go-alpine-patches && \
  export PATH="/usr/local/go/bin:$PATH"; \
  go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

COPY test/go-wrapper /usr/local/bin/
COPY ./test/test.sh /test.sh

WORKDIR /go/src/app
COPY context	    ./context
COPY server.go   ./server.go

RUN sleep 1 && \
    chmod +x /usr/local/bin/go-wrapper && \
    sleep 1 && \
    go-wrapper download && \
    go-wrapper install && \
    go build -o /server server.go && \
    go get github.com/fission/fission && \
    npm install -g newman && \
    npm cache clean --force && \
    rm -rf /root/.cache && \
    rm -rf /var/cache/apk/*

ENTRYPOINT [ "/test.sh" ]

EXPOSE 8888