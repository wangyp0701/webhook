FROM        golang:alpine3.11 AS build
WORKDIR     /go/src/github.com/adnanh/webhook
ENV         WEBHOOK_VERSION 2.7.0
RUN         apk add --update -t build-deps curl libc-dev gcc libgcc
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            tar -xzf webhook.tar.gz --strip 1 &&  \
            go get -d && \
            go build -o /usr/local/bin/webhook && \
            apk del --purge build-deps && \
            rm -rf /var/cache/apk/* && \
            rm -rf /go

FROM        alpine:3.11
ENV TZ Asia/Shanghai
MAINTAINER wangyunpeng <wangyp0701@gmail.com>
RUN apk add --no-cache tzdata git openssh-client expect
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR     /code/webhook
VOLUME      ["/code/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook" , "-hooks" , "/code/webhook/hooks.json" , "-verbose"]
