/*
 Use Case: การประมวลผลข้อมูลหลายชุดพร้อมกัน เช่น การประมวลผลภาพถ่ายหลายไฟล์พร้อมกันเพื่อประหยัดเวลา
 */

import Foundation

func processFilesConcurrently() {
    let concurrentQueue = DispatchQueue(label: "com.example.concurrentQueue", attributes: .concurrent)
    
    concurrentQueue.async {
        print("Processing file 1")
        sleep(2) // จำลองการประมวลผล
        print("Finished processing file 1")
    }
    
    concurrentQueue.async {
        print("Processing file 2")
        sleep(3) // จำลองการประมวลผล
        print("Finished processing file 2")
    }
    
    concurrentQueue.async {
        print("Processing file 3")
        sleep(1) // จำลองการประมวลผล
        print("Finished processing file 3")
    }
    
    print("Tasks are queued, execution will be concurrent")
}

processFilesConcurrently()

/*
 Tasks are queued, execution will be concurrent
 Processing file 1
 Processing file 2
 Processing file 3
 Finished processing file 3
 Finished processing file 1
 Finished processing file 2
 */
