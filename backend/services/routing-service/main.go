package main

import (
	"log"
	"net/http"
	"os"

	"github.com/kinnav/routing-service/handlers"
	"github.com/kinnav/routing-service/models"
)

func main() {
	graphPath := os.Getenv("GRAPH_PATH")
	graph, err := models.LoadGraph(graphPath)
	if err != nil {
		log.Fatalf("load routing graph: %v", err)
	}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", handlers.Health)
	mux.Handle("POST /routes/optimize", handlers.NewRouteHandler(graph))
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}
	log.Printf("routing service listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}
