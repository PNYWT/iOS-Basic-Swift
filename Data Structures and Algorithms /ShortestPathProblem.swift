let INF = Int.max / 2

func floydWarshall(graph: inout [[Int]]) {
    let n = graph.count
    
    for k in 0..<n {
        for i in 0..<n {
            for j in 0..<n {
                if graph[i][k] != INF && graph[k][j] != INF {
                    graph[i][j] = min(graph[i][j], graph[i][k] + graph[k][j])
                }
            }
        }
    }
}

var graph = [
    [0, 3, INF, INF],
    [2, 0, INF, 1],
    [INF, 7, 0, 2],
    [INF, INF, 3, 0]
]

floydWarshall(graph: &graph)

print("ผลลัพธ์ของการหาเส้นทางที่สั้นที่สุดคือ:")
for row in graph {
    print(row)
}
