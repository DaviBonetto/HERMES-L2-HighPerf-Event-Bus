# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install protoc and dependencies
RUN apk add --no-cache git make protobuf-dev

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Install gRPC plugins
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Copy source code
COPY . .

# Generate proto and build
RUN make proto
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hermes-server ./cmd/server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hermes-client ./cmd/client

# Runtime stage
FROM alpine:3.19

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/hermes-server .
COPY --from=builder /app/hermes-client .

EXPOSE 50051

CMD ["./hermes-server"]
