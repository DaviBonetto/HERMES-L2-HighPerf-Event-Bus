#!/bin/bash
set -e

# Clean environment
export HOME=/home/avib
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd "$(dirname "$0")"

echo "=== HERMES Complete Build ===" 
echo ""

# Step 1: Install Go plugins
echo "[1/6] Installing protoc plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
echo "✓ Plugins installed"

# Step 2: Generate protobuf code
echo ""
echo "[2/6] Generating protobuf code..."
mkdir -p pb
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       proto/service.proto
echo "✓ Protobuf code generated"

# Step 3: Download dependencies  
echo ""
echo "[3/6] Downloading dependencies..."
go mod tidy
echo "✓ Dependencies ready"

# Step 4: Build server
echo ""
echo "[4/6] Building server..."
go build -o bin/hermes-server ./cmd/server
echo "✓ Server built: bin/hermes-server"

# Step 5: Build client
echo ""
echo "[5/6] Building client..."
go build -o bin/hermes-client ./cmd/client
echo "✓ Client built: bin/hermes-client"

# Step 6: Run tests
echo ""
echo "[6/6] Running tests..."
go test -v ./internal/...
echo "✓ All tests passed"

echo ""
echo "=== Build Complete ==="
echo ""
echo "Binaries ready in bin/"
echo ""
echo "To test real-time Pub/Sub:"
echo "  Terminal 1: ./bin/hermes-server"
echo "  Terminal 2: ./bin/hermes-client -mode=sub -topic=agents"
echo "  Terminal 3: ./bin/hermes-client -mode=pub -topic=agents"
