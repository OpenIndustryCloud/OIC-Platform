FROM node:8-alpine

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
ENV FUNCTION_PATH="./"

RUN apk update && \
	apk add --no-cache \
		curl \
		jq \
		bash && \
	rm -rf /var/cache/apk/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
COPY ./test/test.sh /test.sh
RUN chmod +x /test.sh && \
	npm install && \
	npm install -g newman && \
	npm cache clean --force
COPY server.js /usr/src/app/server.js

ENTRYPOINT [ "/test.sh" ]

EXPOSE 8888