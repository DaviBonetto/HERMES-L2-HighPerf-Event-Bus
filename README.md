<div align="center">

```
  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗
  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝
  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗
  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║
  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝
```

### ⚡ System 08/300: High-Performance Event Bus

[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org)
[![gRPC](https://img.shields.io/badge/Protocol-gRPC-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://grpc.io)
[![Protobuf](https://img.shields.io/badge/Serialization-Protobuf-FF6F00?style=for-the-badge)](https://protobuf.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**Decentralized Pub/Sub for the Titan Protocol**

---

[Quick Start](#-quick-start) • [Architecture](#-architecture) • [API](#-api)

</div>

---

## 🚀 Quick Start

```bash
# 1. Install Dependencies & Generate Proto
make proto
make deps

# 2. Run Server (Terminal 1)
make run-server

# 3. Subscribe (Terminal 2)
make run-sub

# 4. Publish (Terminal 3)
make run-pub
```

---

## 🏗️ Architecture

```mermaid
flowchart LR
    subgraph PUBLISHERS ["📤 Publishers"]
        P1["Agent VORTEX"]
        P2["Agent AETHER"]
    end

    subgraph HERMES ["⚡ HERMES Event Bus"]
        direction TB
        Router["🔀 Topic Router"]
        Buffer["📦 Channel Buffer"]
        Dispatcher["🚀 Non-Blocking Dispatcher"]
    end

    subgraph SUBSCRIBERS ["📥 Subscribers"]
        S1["Dashboard"]
        S2["Analytics"]
        S3["Logger"]
    end

    P1 -->|gRPC Publish| Router
    P2 -->|gRPC Publish| Router
    Router --> Buffer
    Buffer --> Dispatcher
    Dispatcher -->|Stream| S1
    Dispatcher -->|Stream| S2
    Dispatcher -->|Stream| S3

    style HERMES fill:#00ADD8,stroke:#fff,stroke-width:2px,color:#fff
    style Router fill:#4285F4,stroke:#fff,color:#fff
```

---

## 📜 API

### Protocol Definition (`proto/service.proto`)

```protobuf
service EventBus {
    rpc Publish(Event) returns (Ack);
    rpc Subscribe(Subscription) returns (stream Event);
}
```

### Messages

| Message        | Fields                                  |
| -------------- | --------------------------------------- |
| `Event`        | `topic`, `payload (bytes)`, `timestamp` |
| `Ack`          | `success`, `message`                    |
| `Subscription` | `topic`                                 |

---

## 📁 Project Structure

```
.
├── cmd/
│   ├── server/main.go   # Event Bus Server
│   └── client/main.go   # CLI Client (Pub/Sub)
├── proto/
│   └── service.proto    # gRPC Service Definition
├── pb/                  # Generated Go code (after `make proto`)
├── Makefile
└── README.md
```

---

## 🔧 CLI Usage

```bash
# Subscribe to a topic
./bin/hermes-client -mode=sub -topic=agents

# Publish to a topic
./bin/hermes-client -mode=pub -topic=agents
```

---

## 🔗 Titan Protocol Initiative

| System     | Name       | Technology     |
| ---------- | ---------- | -------------- |
| 06/300     | AETHER     | Python + Voice |
| 07/300     | HELIOS     | Solana + Rust  |
| **08/300** | **HERMES** | **Go + gRPC**  |

---

<div align="center">

**Built with ⚡ Go + 🔗 gRPC by [Davi Bonetto](https://github.com/DaviBonetto)**

_Part of the Titan Protocol Initiative_

</div>
