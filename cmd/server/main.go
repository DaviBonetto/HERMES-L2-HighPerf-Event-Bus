package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	pb "github.com/DaviBonetto/HERMES-L2-HighPerf-Event-Bus/pb"
	"google.golang.org/grpc"
)

// Color codes for terminal output
const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorBlue   = "\033[34m"
	colorCyan   = "\033[36m"
)

// Subscriber represents a client subscribed to a topic
type Subscriber struct {
	stream pb.EventBus_SubscribeServer
	done   chan struct{}
}

// EventBusServer implements the gRPC EventBus service
type EventBusServer struct {
	pb.UnimplementedEventBusServer
	subscribers sync.Map // map[topic][]Subscriber
	mu          sync.RWMutex
}

// NewEventBusServer creates a new EventBusServer instance
func NewEventBusServer() *EventBusServer {
	return &EventBusServer{}
}

// Publish handles incoming events and broadcasts to subscribers
func (s *EventBusServer) Publish(ctx context.Context, event *pb.Event) (*pb.Ack, error) {
	topic := event.Topic
	timestamp := time.Unix(0, event.Timestamp).Format("15:04:05")

	log.Printf("%s[PUB]%s Topic: %s%s%s | Size: %d bytes | Time: %s",
		colorGreen, colorReset,
		colorCyan, topic, colorReset,
		len(event.Payload), timestamp)

	// Get subscribers for this topic
	if subs, ok := s.subscribers.Load(topic); ok {
		subscribers := subs.([]*Subscriber)
		activeCount := 0

		for _, sub := range subscribers {
			select {
			case <-sub.done:
				// Subscriber disconnected, skip
				continue
			default:
				// Non-blocking send to subscriber
				go func(subscriber *Subscriber) {
					if err := subscriber.stream.Send(event); err != nil {
						log.Printf("%s[WARN]%s Failed to send to subscriber: %v", colorYellow, colorReset, err)
					}
				}(sub)
				activeCount++
			}
		}

		log.Printf("%s[BROADCAST]%s Sent to %d active subscribers on '%s'",
			colorBlue, colorReset, activeCount, topic)
	}

	return &pb.Ack{
		Success: true,
		Message: fmt.Sprintf("Event published to topic '%s'", topic),
	}, nil
}

// Subscribe registers a new subscriber for a topic and streams events
func (s *EventBusServer) Subscribe(sub *pb.Subscription, stream pb.EventBus_SubscribeServer) error {
	topic := sub.Topic
	done := make(chan struct{})

	subscriber := &Subscriber{
		stream: stream,
		done:   done,
	}

	// Add subscriber to topic
	s.mu.Lock()
	existing, _ := s.subscribers.LoadOrStore(topic, []*Subscriber{})
	subscribers := append(existing.([]*Subscriber), subscriber)
	s.subscribers.Store(topic, subscribers)
	s.mu.Unlock()

	log.Printf("%s[SUB]%s New subscriber registered for topic: %s%s%s",
		colorYellow, colorReset,
		colorCyan, topic, colorReset)

	// Keep connection alive until client disconnects
	<-stream.Context().Done()

	// Mark subscriber as done
	close(done)

	log.Printf("%s[UNSUB]%s Subscriber disconnected from topic: %s",
		colorYellow, colorReset, topic)

	return nil
}

func main() {
	port := flag.Int("port", 50051, "Server port")
	flag.Parse()

	// ASCII Art Banner
	fmt.Println(`
  ╦ ╦╔═╗╦═╗╔╦╗╔═╗╔═╗
  ╠═╣║╣ ╠╦╝║║║║╣ ╚═╗
  ╩ ╩╚═╝╩╚═╩ ╩╚═╝╚═╝
  ━━━━━━━━━━━━━━━━━━━━
  System 08/300 | L2 Event Bus
  `)

	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterEventBusServer(grpcServer, NewEventBusServer())

	log.Printf("%s[HERMES]%s Server listening on port %d", colorGreen, colorReset, *port)
	log.Printf("%s[READY]%s Awaiting connections...", colorGreen, colorReset)

	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
