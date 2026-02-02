# Changelog

All notable changes to HERMES will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### Added

- Initial release of HERMES Event Bus
- gRPC-based Pub/Sub architecture
- Topic-based message routing
- Non-blocking event dispatch using goroutines
- CLI client with publish and subscribe modes
- Protocol Buffers service definition
- Makefile for build automation
- Comprehensive documentation

### Architecture

- `sync.Map` for thread-safe subscriber management
- Server-streaming RPC for real-time event delivery
- Channel-based event fanout

### Dependencies

- Go 1.21+
- google.golang.org/grpc v1.62.0
- google.golang.org/protobuf v1.32.0
