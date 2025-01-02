// ใช้ Dynamic Programming เพื่อเลือกสินค้าที่มีมูลค่าสูงสุดภายใต้ข้อจำกัดของน้ำหนัก

func knapsack(maxWeight: Int, weights: [Int], values: [Int], n: Int) -> Int {
    var dp = Array(repeating: Array(repeating: 0, count: maxWeight + 1), count: n + 1)
    
    for i in 0...n {
        for w in 0...maxWeight {
            if i == 0 || w == 0 {
                dp[i][w] = 0
            } else if weights[i - 1] <= w {
                dp[i][w] = max(values[i - 1] + dp[i - 1][w - weights[i - 1]], dp[i - 1][w])
            } else {
                dp[i][w] = dp[i - 1][w]
            }
        }
    }
    
    return dp[n][maxWeight]
}

let values: [Int] = [60, 100, 120]
let weights: [Int] = [10, 20, 30]
let maxWeight: Int = 50
let n: Int = values.count

print("มูลค่าสูงสุดที่สามารถใส่ในกระเป๋าได้คือ \(knapsack(maxWeight: maxWeight, weights: weights, values: values, n: n))")
