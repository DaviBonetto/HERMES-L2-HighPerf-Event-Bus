# HERMES API Documentation

## Overview

HERMES provides a high-performance, topic-based pub/sub messaging system using gRPC.

## Service Definition

### EventBus Service

#### Publish

Publishes an event to a specific topic.

**Request:** `Event`

- `topic` (string): Target topic name
- `payload` (bytes): Event data
- `timestamp` (int64): Unix nanosecond timestamp

**Response:** `Ack`

- `success` (bool): Whether publish succeeded
- `message` (string): Status message

#### Subscribe

Opens a server-streaming connection to receive events for a topic.

**Request:** `Subscription`

- `topic` (string): Topic to subscribe to

**Response:** `stream Event`

- Continuous stream of events matching the topic

## Error Handling

| Code                | Description          |
| ------------------- | -------------------- |
| `UNAVAILABLE`       | Server not reachable |
| `DEADLINE_EXCEEDED` | Request timeout      |
| `INTERNAL`          | Server error         |

## Examples

### Go Client

```go
conn, _ := grpc.Dial("localhost:50051", grpc.WithInsecure())
client := pb.NewEventBusClient(conn)

// Publish
ack, _ := client.Publish(ctx, &pb.Event{
    Topic:     "agents",
    Payload:   []byte("hello"),
    Timestamp: time.Now().UnixNano(),
})

// Subscribe
stream, _ := client.Subscribe(ctx, &pb.Subscription{Topic: "agents"})
for {
    event, _ := stream.Recv()
    fmt.Println(string(event.Payload))
}
```
