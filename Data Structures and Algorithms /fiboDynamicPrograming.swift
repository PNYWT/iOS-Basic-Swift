func fiboDP(_ n: Int) -> Int {
    if n <= 1 {
        return n
    }
    
    var fib = [Int](repeating: 0, count: n + 1)
    fib[1] = 1
    
    for i in 2...n {
        fib[i] = fib[i - 1] + fib[i - 2]
    }
    
    return fib[n]
}

let resultDP: Int = fiboDP(8)
print("result Dynamic \(resultDP)")