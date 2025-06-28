package api

import (
	"net/http"
	"system-metrics-api/pkg/api/handlers" // Import handlers
)

// NewRouter sets up the HTTP routes for the application
func NewRouter(metricsHandler *handlers.MetricsHandler) *http.ServeMux {
	mux := http.NewServeMux()

	// Define the /metrics endpoint
	mux.HandleFunc("/metrics", metricsHandler.ServeSystemMetrics)

	return mux
}