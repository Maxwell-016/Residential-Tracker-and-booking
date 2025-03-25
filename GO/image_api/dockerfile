FROM golang:1.24.1

WORKDIR /app

ENV GOPROXY=https://goproxy.io,direct  
COPY go.mod .
COPY go.sum .
RUN go mod tidy  # Try again with the new proxy setting

COPY . .

RUN go build -o bin .

ENTRYPOINT [ "/app/bin" ]
