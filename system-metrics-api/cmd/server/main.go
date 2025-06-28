package main

import (
	"log"
	"net/http"
	"system-metrics-api/pkg/api"
	"system-metrics-api/pkg/api/handlers"
	"system-metrics-api/pkg/metrics"
)

func main() {
	// Initialize metrics collector
	collector := metrics.NewCollector()

	// Initialize API handlers with the collector
	metricsHandler := handlers.NewMetricsHandler(collector)

	// Initialize the router with the handler
	router := api.NewRouter(metricsHandler)

	// Start the server
	port := "8080"
	log.Printf("System Metrics API server starting on port %s...", port)
	log.Fatal(http.ListenAndServe(":"+port, router))
}