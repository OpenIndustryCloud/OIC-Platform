FROM node:8-alpine

RUN npm install -g newman && \
	npm cache clean --force

RUN apk update && \
	apk add --no-cache python3 \
		python3-dev \
		build-base \
		curl \
		jq \
		bash && \
	pip3 install --upgrade pip && \
	rm -r /root/.cache && \
	rm -rf /var/cache/apk/*

COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt

ADD ./test/test.sh /test.sh

ENTRYPOINT [ "/test.sh" ]
