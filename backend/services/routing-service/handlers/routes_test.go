package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/kinnav/routing-service/models"
)

func TestOptimizeReturnsDirectedPathAndPolyline(t *testing.T) {
	graph := &models.Graph{
		Nodes: map[string]models.Node{
			"start": {ID: "start", Lat: -4.325, Lng: 15.322},
			"end":   {ID: "end", Lat: -4.326, Lng: 15.323},
		},
		Edges: []models.Edge{{From: "start", To: "end", RoadName: "Avenue Test", RoadType: "primary"}},
	}
	handler := NewRouteHandler(graph)
	body := []byte(`{"origin":{"lat":-4.325,"lng":15.322},"destination":{"lat":-4.326,"lng":15.323}}`)
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, httptest.NewRequest(http.MethodPost, "/routes/optimize", bytes.NewReader(body)))
	if response.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", response.Code, response.Body.String())
	}
	var result struct {
		Routes []routeResult `json:"routes"`
	}
	if err := json.Unmarshal(response.Body.Bytes(), &result); err != nil {
		t.Fatal(err)
	}
	if len(result.Routes) != 1 || result.Routes[0].Polyline == "" ||
		len(result.Routes[0].RoadNames) != 1 || result.Routes[0].RoadNames[0] != "Avenue Test" {
		t.Fatalf("unexpected route response: %+v", result)
	}

	reverse := []byte(`{"origin":{"lat":-4.326,"lng":15.323},"destination":{"lat":-4.325,"lng":15.322}}`)
	response = httptest.NewRecorder()
	handler.ServeHTTP(response, httptest.NewRequest(http.MethodPost, "/routes/optimize", bytes.NewReader(reverse)))
	if response.Code != http.StatusNotFound {
		t.Fatalf("one-way edge should not allow reverse travel, got %d", response.Code)
	}
}

func TestOptimizeRejectsMissingCoordinates(t *testing.T) {
	graph := &models.Graph{Nodes: map[string]models.Node{
		"node": {ID: "node", Lat: -4.325, Lng: 15.322},
	}}
	handler := NewRouteHandler(graph)
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, httptest.NewRequest(http.MethodPost, "/routes/optimize",
		bytes.NewBufferString(`{"origin":{},"destination":{"lat":-4.325,"lng":15.322}}`)))
	if response.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 for missing coordinate, got %d", response.Code)
	}
}
