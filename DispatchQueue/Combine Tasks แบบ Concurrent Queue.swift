/*
 Use Case
 - มี Tasks 3 งานที่สามารถทำงานพร้อมกัน เช่น การโหลดข้อมูลจาก API
 รอผลลัพธ์ของทุก Task และรวมผลลัพธ์
 */

import Combine
import Foundation

// ฟังก์ชันจำลองงาน (Asynchronous Task)
func performTask(index: Int) -> AnyPublisher<String, Never> {
    Future { promise in
        DispatchQueue.global().async {
            print("Start Task \(index)")
            sleep(index) // จำลองเวลาทำงานที่แตกต่างกัน
            print("End Task \(index)")
            promise(.success("Task \(index) completed"))
        }
    }
    .eraseToAnyPublisher()
}

// สร้าง Tasks หลายงาน
let tasks = [performTask(index: 1), performTask(index: 2), performTask(index: 3)]

// ใช้ Publishers.MergeMany เพื่อรวม Tasks
let cancellable = Publishers.MergeMany(tasks)
    .subscribe(on: DispatchQueue.global()) // ทำงานบน Concurrent Queue
    .collect() // รวบรวมผลลัพธ์ของ Tasks ทั้งหมด
    .receive(on: DispatchQueue.main) // กลับมาที่ Main Queue สำหรับอัปเดต UI
    .sink { results in
        print("All tasks completed: \(results)")
    }


/*
 Start Task 1
 Start Task 2
 Start Task 3
 End Task 1
 End Task 2
 End Task 3
 All tasks completed: ["Task 1 completed", "Task 2 completed", "Task 3 completed"]
 */


// MARK: Best Practices มีการจัดการกับ Error
func performTaskWithError(index: Int) -> AnyPublisher<String, Error> {
    Future { promise in
        DispatchQueue.global().async {
            print("Start Task \(index)")
            sleep(index)
            
            if index == 2 {
                promise(.failure(NSError(domain: "TaskError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task \(index) failed"])))
            } else {
                print("End Task \(index)")
                promise(.success("Task \(index) completed"))
            }
        }
    }
    .eraseToAnyPublisher()
}

// สร้าง Tasks หลายงาน
let errorTasks = [performTaskWithError(index: 1), performTaskWithError(index: 2), performTaskWithError(index: 3)]

// รวม Tasks และจัดการ Error
let errorCancellable = Publishers.MergeMany(errorTasks)
    .subscribe(on: DispatchQueue.global())
    .collect()
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("All tasks completed successfully")
        case .failure(let error):
            print("Error occurred: \(error.localizedDescription)")
        }
    }, receiveValue: { results in
        print("Results: \(results)")
    })

/*
 Start Task 1
 Start Task 2
 Start Task 3
 End Task 1
 Error occurred: Task 2 failed
 
 */
