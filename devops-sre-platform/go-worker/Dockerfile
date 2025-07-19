# -------- Stage 1: Build the Go binary --------
FROM golang:1.22-alpine AS builder
WORKDIR /app

# Copy go.mod and go.sum first (for caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the Go app
RUN go build -o go-worker main.go

# -------- Stage 2: Create a lightweight image --------
FROM alpine:latest
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/go-worker .

# Expose the Prometheus metrics port
EXPOSE 2112

# Run the binary
ENTRYPOINT ["./go-worker"]