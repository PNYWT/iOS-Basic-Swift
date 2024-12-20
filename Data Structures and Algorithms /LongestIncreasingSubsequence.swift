func longestIncreasingSubsequence(arr: [Int]) -> Int {
    let n: Int = arr.count
    var lis: [Int] = Array(repeating: 1, count: n)
    
    for i: Int in 1..<n {
        for j: Int in 0..<i {
            if arr[i] > arr[j] && lis[i] < lis[j] + 1 {
                lis[i] = lis[j] + 1
            }
        }
    }
    return lis.max() ?? 1
}

let stockPrices = [10, 22, 9, 33, 21, 50, 41, 60, 80]
print("ลำดับที่ยาวที่สุดของราคาหุ้นที่เพิ่มขึ้นคือ \(longestIncreasingSubsequence(arr: stockPrices))")
