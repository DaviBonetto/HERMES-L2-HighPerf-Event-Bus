#!/bin/bash
# Clean build script - run with: bash build_final.sh

# Force clean environment
unset PATH
export HOME=/home/avib
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Navigate to project
cd /mnt/c/Users/Davib/OneDrive/Área\ de\ Trabalho/300\ Projetos/1/HERMES-L2-HighPerf-Event-Bus || exit 1

echo "=== HERMES Final Build ==="
echo ""

# Generate protobuf
echo "[1/4] Generating protobuf code..."
mkdir -p pb  
$GOPATH/bin/protoc-gen-go --version
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       proto/service.proto
echo "✓ Generated pb/service.pb.go and pb/service_grpc.pb.go"

# Tidy dependencies
echo ""
echo "[2/4] Tidying dependencies..."
go mod tidy
echo "✓ go.sum updated"

# Build server
echo ""
echo "[3/4] Building binaries..."
mkdir -p bin
go build -o bin/hermes-server ./cmd/server
go build -o bin/hermes-client ./cmd/client
echo "✓ Built bin/hermes-server and bin/hermes-client"

# Run tests
echo ""
echo "[4/4] Running tests..."
go test -v ./internal/...

echo ""
echo "=== BUILD SUCCESSFUL ==="
echo ""
ls -lh bin/
