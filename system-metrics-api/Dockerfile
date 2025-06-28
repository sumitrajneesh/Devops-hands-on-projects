# Stage 1: Build the Go application
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum to cache dependencies
COPY go.mod .
COPY go.sum .

# Download dependencies
RUN go mod download

# Copy the entire backend source code
COPY . .

# Build the Go application
# -o: output file name
# -ldflags="-s -w": reduce binary size by removing debug info
# CGO_ENABLED=0: Disables CGo, creates a statically linked binary (good for Alpine)
# GOOS=linux: Target Linux OS
# The path to main.go is now ./cmd/server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o metrics-api ./cmd/server

# Stage 2: Create a minimal image to run the application
FROM alpine:latest

WORKDIR /root/

# Copy the compiled application from the builder stage
COPY --from=builder /app/metrics-api .

# Expose the port the Go application listens on
EXPOSE 8080

# Command to run the application
CMD ["./metrics-api"]