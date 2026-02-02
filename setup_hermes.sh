#!/bin/bash
set -e

# ==============================================================================
# PROJECT HERMES: SYSTEM 08/300 - HIGH-PERFORMANCE EVENT BUS
# ------------------------------------------------------------------------------
# 🛠️ Toolchain Setup & Project Build
# ==============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[HERMES]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ASCII Banner
echo '
  ╦ ╦╔═╗╦═╗╔╦╗╔═╗╔═╗
  ╠═╣║╣ ╠╦╝║║║║╣ ╚═╗
  ╩ ╩╚═╝╩╚═╩ ╩╚═╝╚═╝
  ━━━━━━━━━━━━━━━━━━━━
  System 08/300 | Setup
'

# 1. 📦 System Dependencies
log "Installing System Dependencies..."
sudo apt-get update
sudo apt-get install -y protobuf-compiler golang-go git make

# 2. 🔧 Configure Go Environment
log "Configuring Go Environment..."
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Add to bashrc if not already there
if ! grep -q "GOPATH" ~/.bashrc; then
    echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
    echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.bashrc
    log "Added GOPATH to ~/.bashrc"
fi

# 3. 📡 Install gRPC Plugins
log "Installing gRPC Go Plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
success "gRPC plugins installed"

# 4. 📂 Navigate to Project
PROJECT_DIR="HERMES-L2-HighPerf-Event-Bus"
REPO_URL="https://github.com/DaviBonetto/HERMES-L2-HighPerf-Event-Bus.git"

if [ ! -d "$PROJECT_DIR" ]; then
    log "Cloning Repository..."
    git clone "$REPO_URL"
fi

cd "$PROJECT_DIR"

# 5. 📜 Generate Protobuf Code
log "Generating Protobuf Code..."
mkdir -p pb
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    proto/service.proto
mv proto/*.pb.go pb/ 2>/dev/null || true
success "Proto files generated in pb/"

# 6. 📦 Download Dependencies
log "Downloading Go Dependencies..."
go mod tidy
go mod download
success "Dependencies installed"

# 7. 🔨 Build Binaries
log "Building Binaries..."
mkdir -p bin
go build -o bin/hermes-server ./cmd/server
go build -o bin/hermes-client ./cmd/client
success "Binaries created: bin/hermes-server, bin/hermes-client"

# 8. ✅ Verification
log "Running Quick Verification..."
echo ""
echo "=== Server Binary ==="
./bin/hermes-server --help 2>/dev/null || echo "(Server ready - no --help flag)"
echo ""
echo "=== Client Binary ==="
./bin/hermes-client --help

success "HERMES Setup Complete! ☀️"
echo ""
log "To run:"
echo "  Terminal 1: ./bin/hermes-server"
echo "  Terminal 2: ./bin/hermes-client -mode=sub -topic=agents"
echo "  Terminal 3: ./bin/hermes-client -mode=pub -topic=agents"
