// Package broker implements the core pub/sub message broker.
package broker

import (
	"sync"
)

// Subscriber represents a subscriber channel.
type Subscriber struct {
	ID    string
	Ch    chan []byte
	Topic string
}

// Broker manages topic subscriptions and message routing.
type Broker struct {
	subscribers sync.Map // map[topic][]*Subscriber
	mu          sync.RWMutex
}

// New creates a new Broker instance.
func New() *Broker {
	return &Broker{}
}

// Subscribe registers a new subscriber for a topic.
func (b *Broker) Subscribe(topic string, sub *Subscriber) {
	b.mu.Lock()
	defer b.mu.Unlock()

	existing, _ := b.subscribers.LoadOrStore(topic, []*Subscriber{})
	subscribers := append(existing.([]*Subscriber), sub)
	b.subscribers.Store(topic, subscribers)
}

// Unsubscribe removes a subscriber from a topic.
func (b *Broker) Unsubscribe(topic string, subID string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	if subs, ok := b.subscribers.Load(topic); ok {
		subscribers := subs.([]*Subscriber)
		filtered := make([]*Subscriber, 0, len(subscribers))
		for _, s := range subscribers {
			if s.ID != subID {
				filtered = append(filtered, s)
			}
		}
		b.subscribers.Store(topic, filtered)
	}
}

// Publish sends a message to all subscribers of a topic.
func (b *Broker) Publish(topic string, payload []byte) int {
	subs, ok := b.subscribers.Load(topic)
	if !ok {
		return 0
	}

	subscribers := subs.([]*Subscriber)
	count := 0

	for _, sub := range subscribers {
		select {
		case sub.Ch <- payload:
			count++
		default:
			// Non-blocking: skip if channel is full
		}
	}

	return count
}

// TopicCount returns the number of subscribers for a topic.
func (b *Broker) TopicCount(topic string) int {
	if subs, ok := b.subscribers.Load(topic); ok {
		return len(subs.([]*Subscriber))
	}
	return 0
}
