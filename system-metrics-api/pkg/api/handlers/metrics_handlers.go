package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"system-metrics-api/pkg/metrics" // Import the metrics package
)

// MetricsHandler holds the metrics collector dependency
type MetricsHandler struct {
	collector *metrics.Collector
}

// NewMetricsHandler creates a new metrics handler
func NewMetricsHandler(c *metrics.Collector) *MetricsHandler {
	return &MetricsHandler{collector: c}
}

// ServeSystemMetrics handles GET requests to /metrics
func (h *MetricsHandler) ServeSystemMetrics(w http.ResponseWriter, r *http.Request) {
	// Set CORS headers (optional, but good for local development with a frontend)
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	systemMetrics, err := h.collector.CollectAllMetrics()
	if err != nil {
		// Log the error, but still try to return what we have or a specific error message
		log.Printf("Error collecting system metrics: %v", err)
		http.Error(w, "Failed to collect all system metrics", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(systemMetrics)
}