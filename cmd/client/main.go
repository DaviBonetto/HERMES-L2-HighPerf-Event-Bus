package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
	"time"

	pb "github.com/DaviBonetto/HERMES-L2-HighPerf-Event-Bus/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorCyan   = "\033[36m"
)

func main() {
	mode := flag.String("mode", "sub", "Mode: 'pub' or 'sub'")
	topic := flag.String("topic", "default", "Topic to publish/subscribe")
	addr := flag.String("addr", "localhost:50051", "Server address")
	flag.Parse()

	// Connect to server
	conn, err := grpc.NewClient(*addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	client := pb.NewEventBusClient(conn)

	fmt.Printf("%s[HERMES CLIENT]%s Connected to %s\n", colorGreen, colorReset, *addr)
	fmt.Printf("Mode: %s%s%s | Topic: %s%s%s\n",
		colorCyan, *mode, colorReset,
		colorYellow, *topic, colorReset)
	fmt.Println(strings.Repeat("─", 40))

	switch *mode {
	case "pub":
		runPublisher(client, *topic)
	case "sub":
		runSubscriber(client, *topic)
	default:
		log.Fatalf("Invalid mode: %s. Use 'pub' or 'sub'", *mode)
	}
}

func runPublisher(client pb.EventBusClient, topic string) {
	fmt.Println("📤 Publisher Mode - Type messages to publish (Ctrl+C to exit):")
	scanner := bufio.NewScanner(os.Stdin)

	for {
		fmt.Print("> ")
		if !scanner.Scan() {
			break
		}
		message := scanner.Text()
		if message == "" {
			continue
		}

		event := &pb.Event{
			Topic:     topic,
			Payload:   []byte(message),
			Timestamp: time.Now().UnixNano(),
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		ack, err := client.Publish(ctx, event)
		cancel()

		if err != nil {
			log.Printf("Failed to publish: %v", err)
			continue
		}

		fmt.Printf("%s[ACK]%s %s\n", colorGreen, colorReset, ack.Message)
	}
}

func runSubscriber(client pb.EventBusClient, topic string) {
	fmt.Printf("📥 Subscriber Mode - Listening on topic '%s'...\n", topic)

	ctx := context.Background()
	stream, err := client.Subscribe(ctx, &pb.Subscription{Topic: topic})
	if err != nil {
		log.Fatalf("Failed to subscribe: %v", err)
	}

	for {
		event, err := stream.Recv()
		if err == io.EOF {
			log.Println("Stream closed by server")
			break
		}
		if err != nil {
			log.Fatalf("Error receiving event: %v", err)
		}

		timestamp := time.Unix(0, event.Timestamp).Format("15:04:05")
		fmt.Printf("%s[%s]%s [%s] %s\n",
			colorCyan, topic, colorReset,
			timestamp,
			string(event.Payload))
	}
}
