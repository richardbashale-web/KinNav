package algorithms

import (
	"container/heap"
	"math"

	"github.com/kinnav/routing-service/models"
)

type Path struct {
	NodeIDs  []string
	Distance float64
}

type neighbor struct {
	id       string
	distance float64
	weight   float64
}

type item struct {
	id       string
	priority float64
	index    int
}

type priorityQueue []*item

func (q priorityQueue) Len() int { return len(q) }
func (q priorityQueue) Less(i, j int) bool { return q[i].priority < q[j].priority }
func (q priorityQueue) Swap(i, j int) { q[i], q[j] = q[j], q[i]; q[i].index, q[j].index = i, j }
func (q *priorityQueue) Push(value any) { entry := value.(*item); entry.index = len(*q); *q = append(*q, entry) }
func (q *priorityQueue) Pop() any {
	old := *q
	last := len(old) - 1
	entry := old[last]
	*q = old[:last]
	return entry
}

func FindPath(graph *models.Graph, start, goal string) (Path, bool) {
	if _, ok := graph.Nodes[start]; !ok {
		return Path{}, false
	}
	if _, ok := graph.Nodes[goal]; !ok {
		return Path{}, false
	}
	adjacency := make(map[string][]neighbor)
	for _, edge := range graph.Edges {
		from, to := graph.Nodes[edge.From], graph.Nodes[edge.To]
		adjacency[edge.From] = append(adjacency[edge.From], neighbor{
			id: edge.To, distance: haversine(from, to), weight: roadWeight(edge.RoadType),
		})
	}
	open := &priorityQueue{}
	heap.Init(open)
	heap.Push(open, &item{id: start})
	cost := map[string]float64{start: 0}
	previous := make(map[string]string)
	for open.Len() > 0 {
		current := heap.Pop(open).(*item).id
		if current == goal {
			path := []string{goal}
			for path[len(path)-1] != start {
				path = append(path, previous[path[len(path)-1]])
			}
			for left, right := 0, len(path)-1; left < right; left, right = left+1, right-1 {
				path[left], path[right] = path[right], path[left]
			}
			distance := 0.0
			for index := 1; index < len(path); index++ {
				distance += haversine(graph.Nodes[path[index-1]], graph.Nodes[path[index]])
			}
			return Path{NodeIDs: path, Distance: distance}, true
		}
		for _, next := range adjacency[current] {
			candidate := cost[current] + next.distance*next.weight
			currentCost, visited := cost[next.id]
			if !visited || candidate < currentCost {
				cost[next.id] = candidate
				previous[next.id] = current
				heap.Push(open, &item{id: next.id, priority: candidate + haversine(graph.Nodes[next.id], graph.Nodes[goal])})
			}
		}
	}
	return Path{}, false
}

func roadWeight(roadType string) float64 {
	switch roadType {
	case "primary":
		return 1
	case "secondary":
		return 1.15
	case "residential":
		return 1.3
	case "unclassified":
		return 1.5
	default:
		return 1.2
	}
}

func haversine(a, b models.Node) float64 {
	const radius = 6371000
	lat1, lat2 := a.Lat*math.Pi/180, b.Lat*math.Pi/180
	dLat, dLng := (b.Lat-a.Lat)*math.Pi/180, (b.Lng-a.Lng)*math.Pi/180
	h := math.Sin(dLat/2)*math.Sin(dLat/2) + math.Cos(lat1)*math.Cos(lat2)*math.Sin(dLng/2)*math.Sin(dLng/2)
	return radius * 2 * math.Atan2(math.Sqrt(h), math.Sqrt(1-h))
}
