# Stage 1 (Build)
FROM golang:1.20.11-alpine AS builder

ARG VERSION
RUN apk add --update --no-cache git make
WORKDIR /app/
COPY go.mod go.sum /app/
RUN go mod download
COPY . /app/
RUN CGO_ENABLED=0 go build \
    -ldflags="-s -w -X github.com/pteranodon/buddy/system.Version=$VERSION" \
    -v \
    -trimpath \
    -o buddy \
    buddy.go
RUN echo "ID=\"distroless\"" > /etc/os-release

# Stage 2 (Final)
FROM gcr.io/distroless/static:latest
COPY --from=builder /etc/os-release /etc/os-release

COPY --from=builder /app/buddy /usr/bin/
CMD [ "/usr/bin/buddy", "--config", "/etc/pteranodon/config.yml" ]

EXPOSE 8080
