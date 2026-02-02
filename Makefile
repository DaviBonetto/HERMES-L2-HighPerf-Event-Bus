.PHONY: proto build run-server run-client clean

# Protocol Buffer Generation
proto:
	@echo "Generating Go code from proto..."
	@mkdir -p pb
	protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		proto/service.proto
	@mv proto/*.go pb/
	@echo "Done! Generated files in pb/"

# Build binaries
build: proto
	@echo "Building server..."
	go build -o bin/hermes-server ./cmd/server
	@echo "Building client..."
	go build -o bin/hermes-client ./cmd/client
	@echo "Binaries created in bin/"

# Run server
run-server:
	go run ./cmd/server

# Run subscriber client
run-sub:
	go run ./cmd/client -mode=sub -topic=agents

# Run publisher client
run-pub:
	go run ./cmd/client -mode=pub -topic=agents

# Clean build artifacts
clean:
	rm -rf bin/ pb/

# Install dependencies
deps:
	go mod tidy
	go mod download
