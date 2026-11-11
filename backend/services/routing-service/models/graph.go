package models

import (
	"encoding/json"
	"fmt"
	"math"
	"os"
)

type Node struct {
	ID  string  `json:"id"`
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

type Edge struct {
	From     string `json:"from"`
	To       string `json:"to"`
	RoadName string `json:"road_name"`
	RoadType string `json:"road_type"`
}

type GraphFile struct {
	Nodes []Node `json:"nodes"`
	Edges []Edge `json:"edges"`
}

type Graph struct {
	Nodes map[string]Node
	Edges []Edge
}

func LoadGraph(path string) (*Graph, error) {
	graph := &Graph{Nodes: make(map[string]Node)}
	if path == "" {
		return graph, nil
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read graph %q: %w", path, err)
	}
	var file GraphFile
	if err := json.Unmarshal(data, &file); err != nil {
		return nil, fmt.Errorf("decode graph: %w", err)
	}
	for _, node := range file.Nodes {
		if node.ID == "" || !validCoordinate(node.Lat, node.Lng) {
			return nil, fmt.Errorf("invalid node %q", node.ID)
		}
		graph.Nodes[node.ID] = node
	}
	for _, edge := range file.Edges {
		if _, ok := graph.Nodes[edge.From]; !ok {
			return nil, fmt.Errorf("edge references unknown node %q", edge.From)
		}
		if _, ok := graph.Nodes[edge.To]; !ok {
			return nil, fmt.Errorf("edge references unknown node %q", edge.To)
		}
		graph.Edges = append(graph.Edges, edge)
	}
	return graph, nil
}

func validCoordinate(lat, lng float64) bool {
	return !math.IsNaN(lat) && !math.IsNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
}
