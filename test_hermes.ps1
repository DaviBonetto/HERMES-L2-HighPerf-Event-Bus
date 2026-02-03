# HERMES Build and Test Script
# Run this after restarting PowerShell

Write-Host '=== HERMES Build Test ===' -ForegroundColor Cyan

# 1. Install protoc plugins
Write-Host ''
Write-Host '[1/5] Installing gRPC plugins...' -ForegroundColor Yellow
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# 2. Download dependencies
Write-Host ''
Write-Host '[2/5] Downloading Go dependencies...' -ForegroundColor Yellow
go mod download

# 3. Build server
Write-Host ''
Write-Host '[3/5] Building server...' -ForegroundColor Yellow
go build -o bin/hermes-server.exe ./cmd/server
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Server built successfully' -ForegroundColor Green
}
else {
    Write-Host 'Server build failed' -ForegroundColor Red
    exit 1
}

# 4. Build client
Write-Host ''
Write-Host '[4/5] Building client...' -ForegroundColor Yellow
go build -o bin/hermes-client.exe ./cmd/client
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Client built successfully' -ForegroundColor Green
}
else {
    Write-Host 'Client build failed' -ForegroundColor Red
    exit 1
}

# 5. Run tests
Write-Host ''
Write-Host '[5/5] Running tests...' -ForegroundColor Yellow
go test ./internal/...
if ($LASTEXITCODE -eq 0) {
    Write-Host 'All tests passed' -ForegroundColor Green
}
else {
    Write-Host 'Tests failed' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '=== Build Complete ===' -ForegroundColor Green
Write-Host 'Binaries created in bin/ directory'
Write-Host ''
Write-Host 'To test:'
Write-Host '  Terminal 1: .\bin\hermes-server.exe'
Write-Host '  Terminal 2: .\bin\hermes-client.exe -mode=sub -topic=test'
Write-Host '  Terminal 3: .\bin\hermes-client.exe -mode=pub -topic=test'
