# Contributing to HERMES

First off, thank you for considering contributing to HERMES! 🎉

## Development Setup

### Prerequisites

- Go 1.21+
- Protocol Buffers Compiler (`protoc`)
- gRPC Go plugins

### Quick Start

```bash
# Install dependencies
make deps

# Generate protobuf code
make proto

# Build binaries
make build

# Run tests
make test
```

## Code Style

- Follow standard Go conventions (`gofmt`, `golint`)
- Use meaningful commit messages (Conventional Commits preferred)
- Add tests for new features

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes with descriptive messages
4. Push to your fork
5. Open a Pull Request

## Reporting Issues

When reporting issues, please include:

- Go version (`go version`)
- Operating system
- Steps to reproduce
- Expected vs actual behavior

---

_Part of the Titan Protocol Initiative_
