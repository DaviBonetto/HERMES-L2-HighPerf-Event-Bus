package broker

import (
	"testing"
)

func TestBrokerSubscribe(t *testing.T) {
	b := New()
	
	sub := &Subscriber{
		ID:    "test-1",
		Ch:    make(chan []byte, 10),
		Topic: "agents",
	}
	
	b.Subscribe("agents", sub)
	
	if count := b.TopicCount("agents"); count != 1 {
		t.Errorf("Expected 1 subscriber, got %d", count)
	}
}

func TestBrokerPublish(t *testing.T) {
	b := New()
	
	sub := &Subscriber{
		ID:    "test-1",
		Ch:    make(chan []byte, 10),
		Topic: "agents",
	}
	
	b.Subscribe("agents", sub)
	
	count := b.Publish("agents", []byte("hello"))
	
	if count != 1 {
		t.Errorf("Expected 1 message delivered, got %d", count)
	}
	
	msg := <-sub.Ch
	if string(msg) != "hello" {
		t.Errorf("Expected 'hello', got '%s'", string(msg))
	}
}

func TestBrokerUnsubscribe(t *testing.T) {
	b := New()
	
	sub := &Subscriber{
		ID:    "test-1",
		Ch:    make(chan []byte, 10),
		Topic: "agents",
	}
	
	b.Subscribe("agents", sub)
	b.Unsubscribe("agents", "test-1")
	
	if count := b.TopicCount("agents"); count != 0 {
		t.Errorf("Expected 0 subscribers after unsubscribe, got %d", count)
	}
}

func BenchmarkPublish(b *testing.B) {
	broker := New()
	
	for i := 0; i < 100; i++ {
		sub := &Subscriber{
			ID:    "bench-sub",
			Ch:    make(chan []byte, 1000),
			Topic: "bench",
		}
		broker.Subscribe("bench", sub)
	}
	
	payload := []byte("benchmark message")
	
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		broker.Publish("bench", payload)
	}
}
