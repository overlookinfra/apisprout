FROM golang:1.12-alpine as build
WORKDIR /apisprout
COPY . .
RUN apk add --no-cache git && \
  go run github.com/ahmetb/govvv install

FROM alpine:3.8
COPY --from=build /go/bin/apisprout /usr/local/bin/
RUN apk add --no-cache ca-certificates && \
  update-ca-certificates
ENTRYPOINT ["/usr/local/bin/apisprout"]
EXPOSE 8000
