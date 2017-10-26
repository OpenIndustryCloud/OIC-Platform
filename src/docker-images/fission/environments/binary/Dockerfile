FROM golang:1.8-alpine

ENV GOOS=linux 
ENV GOARCH=386

RUN apk update && \
	apk add coreutils \
		binutils \
		findutils \
		grep && \
	rm -rf /root/.cache && \
	rm -rf /var/cache/apk/*

COPY . /app
WORKDIR /app

RUN go build -o /server .


ENTRYPOINT ["/server"]

EXPOSE 8888