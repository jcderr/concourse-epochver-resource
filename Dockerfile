FROM alpine:latest

ENV runDependencies python py-pip py-boto ca-certificates
RUN apk --no-cache add ${runDependencies}

ADD bin/check /opt/resource/check
ADD bin/in /opt/resource/in
ADD bin/out /opt/resource/out
