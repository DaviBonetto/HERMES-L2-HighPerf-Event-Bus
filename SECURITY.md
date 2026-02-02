# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within HERMES, please send an email to security@titanprotocol.dev.

**Please do not report security vulnerabilities through public GitHub issues.**

We will acknowledge receipt within 48 hours and provide a detailed response within one week.

## Security Measures

HERMES implements the following security practices:

- **Transport Security**: All gRPC connections should use TLS in production
- **Input Validation**: All message payloads are size-limited
- **No Persistence**: Events are not stored, reducing data exposure risk
- **Dependency Scanning**: Regular `go mod audit` runs
