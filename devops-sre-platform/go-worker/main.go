// go-worker/main.go
package main

import (
	"fmt"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    customMetric = prometheus.NewCounter(
        prometheus.CounterOpts{
            Name: "my_custom_requests_total",
            Help: "Total number of custom requests",
        },
    )
)

func main() {
    prometheus.MustRegister(customMetric)

    http.HandleFunc("/trigger", func(w http.ResponseWriter, r *http.Request) {
        customMetric.Inc()
        fmt.Fprintln(w, "Metric incremented")
    })

    http.Handle("/metrics", promhttp.Handler())

    fmt.Println("🚀 Go Worker started on :2112")
    http.ListenAndServe(":2112", nil)
}