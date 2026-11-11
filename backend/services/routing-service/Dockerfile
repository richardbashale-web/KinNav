FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY . .
RUN CGO_ENABLED=0 go build -o /routing-service .
FROM scratch
COPY --from=build /routing-service /routing-service
EXPOSE 8081
ENTRYPOINT ["/routing-service"]
