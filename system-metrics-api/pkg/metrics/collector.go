package metrics

import (
	"errors"
	"log"
	"time"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/mem"
)

// CPUMetrics holds CPU usage information
type CPUMetrics struct {
	Percent float64 `json:"percent"` // CPU usage percentage
}

// MemoryMetrics holds memory usage information
type MemoryMetrics struct {
	Total       uint64  `json:"total_bytes"`
	Available   uint64  `json:"available_bytes"`
	Used        uint64  `json:"used_bytes"`
	UsedPercent float64 `json:"used_percent"`
}

// DiskMetrics holds disk usage information for a given path
type DiskMetrics struct {
	Path        string  `json:"path"`
	Total       uint64  `json:"total_bytes"`
	Free        uint64  `json:"free_bytes"`
	Used        uint64  `json:"used_bytes"`
	UsedPercent float64 `json:"used_percent"`
}

// SystemMetrics combines all collected metrics
type SystemMetrics struct {
	CPU    CPUMetrics    `json:"cpu"`
	Memory MemoryMetrics `json:"memory"`
	Disk   []DiskMetrics `json:"disk_partitions"` // Can be multiple disk partitions
}

// Collector provides methods to gather system metrics
type Collector struct{}

// NewCollector creates a new metrics collector
func NewCollector() *Collector {
	return &Collector{}
}

// GetCPUMetrics collects CPU usage percentage
func (c *Collector) GetCPUMetrics() (CPUMetrics, error) {
	// cpu.Percent returns a slice of percentages for each CPU and overall.
	// We'll take the overall (first element) after 100ms interval.
	percentages, err := cpu.Percent(time.Millisecond*100, false)
	if err != nil {
		log.Printf("Error collecting CPU metrics: %v", err)
		return CPUMetrics{}, err
	}
	if len(percentages) > 0 {
		return CPUMetrics{Percent: percentages[0]}, nil
	}
	return CPUMetrics{Percent: 0}, nil // Should not happen if no error
}

// GetMemoryMetrics collects virtual memory usage
func (c *Collector) GetMemoryMetrics() (MemoryMetrics, error) {
	v, err := mem.VirtualMemory()
	if err != nil {
		log.Printf("Error collecting Memory metrics: %v", err)
		return MemoryMetrics{}, err
	}
	return MemoryMetrics{
		Total:       v.Total,
		Available:   v.Available,
		Used:        v.Used,
		UsedPercent: v.UsedPercent,
	}, nil
}

// GetDiskMetrics collects disk usage for specified paths (e.g., "/")
func (c *Collector) GetDiskMetrics(paths []string) ([]DiskMetrics, error) {
	var diskMetrics []DiskMetrics
	for _, path := range paths {
		usage, err := disk.Usage(path)
		if err != nil {
			log.Printf("Error collecting Disk metrics for path %s: %v", path, err)
			// Continue to next path even if one fails
			continue 
		}
		diskMetrics = append(diskMetrics, DiskMetrics{
			Path:        usage.Path,
			Total:       usage.Total,
			Free:        usage.Free,
			Used:        usage.Used,
			UsedPercent: usage.UsedPercent,
		})
	}
	if len(diskMetrics) == 0 && len(paths) > 0 {
		return nil, errors.New("no disk metrics collected for any specified path")
	}
	return diskMetrics, nil
}

// CollectAllMetrics gathers all system metrics
func (c *Collector) CollectAllMetrics() (SystemMetrics, error) {
	var sm SystemMetrics
	var err error

	// Collect CPU
	sm.CPU, err = c.GetCPUMetrics()
	if err != nil {
		log.Printf("Failed to get CPU metrics: %v", err)
		// Decide if this is a fatal error or if we can proceed with partial data
	}

	// Collect Memory
	sm.Memory, err = c.GetMemoryMetrics()
	if err != nil {
		log.Printf("Failed to get Memory metrics: %v", err)
	}

	// Collect Disk for root partition. You can add more paths like "/mnt/data"
	sm.Disk, err = c.GetDiskMetrics([]string{"/"}) // Common path for Linux root
	if err != nil {
		log.Printf("Failed to get Disk metrics: %v", err)
	}

	// Return the collected metrics. Errors are logged but not aggregated here
	// to allow partial data to be returned. You might want to change this
	// based on your error handling strategy.
	return sm, nil
}