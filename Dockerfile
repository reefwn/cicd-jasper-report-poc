FROM alpine

WORKDIR /usr/cicd

COPY ./scripts /usr/cicd/scripts
COPY ./reports /usr/cicd/reports
COPY ./env /usr/cicd/env

RUN apk add --no-cache curl

RUN chmod +x ./scripts/deploy.sh

ENTRYPOINT ["./scripts/deploy.sh", "development"]