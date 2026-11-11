package algorithms

import (
	"testing"

	"github.com/kinnav/routing-service/models"
)

func TestFindPath(t *testing.T) {
	graph := &models.Graph{
		Nodes: map[string]models.Node{
			"a": {ID: "a", Lat: -4.3, Lng: 15.3},
			"b": {ID: "b", Lat: -4.31, Lng: 15.3},
			"c": {ID: "c", Lat: -4.32, Lng: 15.3},
		},
		Edges: []models.Edge{{From: "a", To: "b"}, {From: "b", To: "c"}},
	}
	path, found := FindPath(graph, "a", "c")
	if !found || len(path.NodeIDs) != 3 || path.NodeIDs[0] != "a" || path.NodeIDs[2] != "c" {
		t.Fatalf("unexpected path: %+v, found=%v", path, found)
	}
	if _, found := FindPath(graph, "a", "unknown"); found { t.Fatal("expected no path") }
}
