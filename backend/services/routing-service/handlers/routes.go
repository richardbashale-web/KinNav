package handlers

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"sort"
	"strings"

	"github.com/kinnav/routing-service/algorithms"
	"github.com/kinnav/routing-service/models"
)

type coordinate struct {
	Lat *float64 `json:"lat"`
	Lng *float64 `json:"lng"`
}
type optimizeRequest struct {
	Origin      coordinate `json:"origin"`
	Destination coordinate `json:"destination"`
}
type routeResult struct {
	ID               string   `json:"id"`
	DurationSeconds  int      `json:"duration_seconds"`
	DistanceMeters   int      `json:"distance_meters"`
	Polyline         string   `json:"polyline"`
	RoadNames        []string `json:"road_names"`
	CongestionLevel  string   `json:"congestion_level"`
	IsRecommended    bool     `json:"is_recommended"`
}

func Health(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_, _ = w.Write([]byte(`{"status":"ok"}`))
}

func NewRouteHandler(graph *models.Graph) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if len(graph.Nodes) == 0 {
			writeError(w, "routing graph is not configured", http.StatusServiceUnavailable)
			return
		}
		r.Body = http.MaxBytesReader(w, r.Body, 64*1024)
		var request optimizeRequest
		decoder := json.NewDecoder(r.Body)
		decoder.DisallowUnknownFields()
		if err := decoder.Decode(&request); err != nil ||
			!valid(request.Origin) || !valid(request.Destination) {
			writeError(w, "invalid origin or destination", http.StatusBadRequest)
			return
		}
		if err := decoder.Decode(&struct{}{}); err != io.EOF {
			writeError(w, "request must contain one JSON object", http.StatusBadRequest)
			return
		}
		start, end := nearest(graph, *request.Origin.Lat, *request.Origin.Lng),
			nearest(graph, *request.Destination.Lat, *request.Destination.Lng)
		path, found := algorithms.FindPath(graph, start.ID, end.ID)
		if !found {
			writeError(w, "no route found", http.StatusNotFound)
			return
		}
		names := make([]string, 0)
		for index := 1; index < len(path.NodeIDs); index++ {
			for _, edge := range graph.Edges {
				if edge.From == path.NodeIDs[index-1] && edge.To == path.NodeIDs[index] {
					if edge.RoadName != "" && (len(names) == 0 || names[len(names)-1] != edge.RoadName) {
						names = append(names, edge.RoadName)
					}
					break
				}
			}
		}
		distance := int(math.Round(path.Distance))
		id, err := newRouteID()
		if err != nil {
			writeError(w, "could not create route identifier", http.StatusInternalServerError)
			return
		}
		result := routeResult{
			ID: id, DurationSeconds: int(math.Round(float64(distance)/8.33)),
			DistanceMeters: distance, Polyline: encodePolyline(graph, path.NodeIDs),
			RoadNames: names, CongestionLevel: "unknown",
			IsRecommended: true,
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string][]routeResult{"routes": []routeResult{result}})
	})
}

func newRouteID() (string, error) {
	var value [16]byte
	if _, err := rand.Read(value[:]); err != nil {
		return "", err
	}
	value[6] = (value[6] & 0x0f) | 0x40
	value[8] = (value[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", value[0:4], value[4:6], value[6:8], value[8:10], value[10:16]), nil
}

func valid(point coordinate) bool {
	return point.Lat != nil && point.Lng != nil &&
		!math.IsNaN(*point.Lat) && !math.IsNaN(*point.Lng) &&
		*point.Lat >= -90 && *point.Lat <= 90 && *point.Lng >= -180 && *point.Lng <= 180
}

func nearest(graph *models.Graph, lat, lng float64) models.Node {
	nodes := make([]models.Node, 0, len(graph.Nodes))
	for _, node := range graph.Nodes {
		nodes = append(nodes, node)
	}
	sort.Slice(nodes, func(i, j int) bool {
		return sq(nodes[i].Lat-lat)+sq(nodes[i].Lng-lng) < sq(nodes[j].Lat-lat)+sq(nodes[j].Lng-lng)
	})
	return nodes[0]
}
func sq(value float64) float64 { return value * value }

func writeError(w http.ResponseWriter, message string, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(map[string]string{"error": message})
}

func encodePolyline(graph *models.Graph, nodeIDs []string) string {
	var encoded strings.Builder
	previousLat, previousLng := 0, 0
	for _, id := range nodeIDs {
		node := graph.Nodes[id]
		lat := int(math.Round(node.Lat * 1e5))
		lng := int(math.Round(node.Lng * 1e5))
		encodeValue(&encoded, lat-previousLat)
		encodeValue(&encoded, lng-previousLng)
		previousLat, previousLng = lat, lng
	}
	return encoded.String()
}

func encodeValue(output *strings.Builder, value int) {
	value <<= 1
	if value < 0 {
		value = ^value
	}
	for value >= 0x20 {
		output.WriteByte(byte((0x20 | (value & 0x1f)) + 63))
		value >>= 5
	}
	output.WriteByte(byte(value + 63))
}
