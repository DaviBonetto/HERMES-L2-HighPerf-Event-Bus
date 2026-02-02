// Package config provides configuration management for HERMES.
package config

import (
	"os"
	"strconv"
)

// ServerConfig holds server configuration options.
type ServerConfig struct {
	Port     int
	LogLevel string
}

// DefaultServerConfig returns the default server configuration.
func DefaultServerConfig() *ServerConfig {
	return &ServerConfig{
		Port:     50051,
		LogLevel: "info",
	}
}

// LoadFromEnv loads configuration from environment variables.
func LoadFromEnv() *ServerConfig {
	cfg := DefaultServerConfig()

	if port := os.Getenv("HERMES_PORT"); port != "" {
		if p, err := strconv.Atoi(port); err == nil {
			cfg.Port = p
		}
	}

	if level := os.Getenv("HERMES_LOG_LEVEL"); level != "" {
		cfg.LogLevel = level
	}

	return cfg
}
