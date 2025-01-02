func fiboRecursive(_ n: Int) -> Int {
    if n <= 1 {
        return n
    }
    return fiboRecursive(n - 1) + fiboRecursive(n - 2)
}

let resultRecursive: Int = fiboRecursive(5)
print("result Recursive \(resultRecursive)")