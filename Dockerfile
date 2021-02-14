FROM --platform=$BUILDPLATFORM golang:1.15.8 AS builder

WORKDIR /build
ARG TARGETOS
ARG TARGETARCH

COPY go.mod go.sum /build/
RUN go mod download
RUN go mod verify

COPY . /build/
RUN make test

ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
RUN make build-binary

FROM busybox
LABEL maintainer="Robert Jacob <xperimental@solidproject.de>"

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /build/nextcloud-exporter /bin/nextcloud-exporter

USER nobody
EXPOSE 9205

ENTRYPOINT ["/bin/nextcloud-exporter"]
