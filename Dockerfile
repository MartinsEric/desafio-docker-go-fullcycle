### Use golang:1.20 as base image for building the application
FROM golang:1.20 as builder

### Create new directly and set it as working directory
RUN mkdir -p /app
WORKDIR /app

### Copy Go application dependency files
COPY go.mod .

### Setting a proxy for downloading modules
ENV GOPROXY https://proxy.golang.org,direct

### Download Go application module dependencies
RUN go mod download

### Copy actual source code for building the application
COPY . .

### CGO has to be disabled cross platform builds
### Otherwise the application won't be able to start
ENV CGO_ENABLED=0

### Build the Go app for a linux OS
### 'scratch' and 'alpine' both are Linux distributions
RUN GOOS=linux go build ./main.go

### Define the running image
FROM scratch

### Set working directory
WORKDIR /app

### Copy built binary application from 'builder' image
COPY --from=builder /app/main .

### Run the binary application
CMD ["/app/main"]