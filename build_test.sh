#!/bin/bash

echo "=== HERMES Build & Test (WSL) ==="

# Install protoc plugins
echo ""
echo "[1/5] Installing gRPC plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Update PATH
export PATH=$PATH:$HOME/go/bin

# Download dependencies
echo ""
echo "[2/5] Downloading dependencies..."
go mod tidy

# Build server
echo ""
echo "[3/5] Building server..."
go build -o bin/hermes-server ./cmd/server
if [ $? -eq 0 ]; then
    echo "✓ Server built successfully"
else
    echo "✗ Server build failed"
    exit 1
fi

# Build client
echo ""
echo "[4/5] Building client..."
go build -o bin/hermes-client ./cmd/client
if [ $? -eq 0 ]; then
    echo "✓ Client built successfully"
else
    echo "✗ Client build failed"
    exit 1
fi

# Run tests
echo ""
echo "[5/5] Running tests..."
go test -v ./internal/...
if [ $? -eq 0 ]; then
    echo "✓ All tests passed"
else
    echo "✗ Tests failed"
    exit 1
fi

echo ""
echo "=== Build Complete ==="
echo "Binaries in bin/ directory"
echo ""
echo "To test:"
echo "  Terminal 1: ./bin/hermes-server"
echo "  Terminal 2: ./bin/hermes-client -mode=sub -topic=test"
echo "  Terminal 3: ./bin/hermes-client -mode=pub -topic=test"
