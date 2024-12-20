func maxInvestment(profits: [Int], budgets: [Int], maxBudget: Int) -> Int {
    let n = profits.count
    var dp = Array(repeating: 0, count: maxBudget + 1)
    
    for i in 0..<n {
        for j in stride(from: maxBudget, through: budgets[i], by: -1) {
            dp[j] = max(dp[j], dp[j - budgets[i]] + profits[i])
        }
    }
    
    return dp[maxBudget]
}

let profits = [100, 200, 300]
let budgets = [10, 20, 30]
let maxBudget = 50

print("ผลตอบแทนสูงสุดที่สามารถได้จากการลงทุนคือ \(maxInvestment(profits: profits, budgets: budgets, maxBudget: maxBudget))")
