/*
 ใช้เมื่อคุณมี tasks หลายงานที่สามารถทำงานพร้อมกัน และต้องการทราบว่า tasks ทั้งหมดเสร็จสิ้นเมื่อใด เช่น การดาวน์โหลดหลายไฟล์พร้อมกัน
 */

let dispatchGroup = DispatchGroup()

dispatchGroup.enter()
DispatchQueue.global().async {
    print("Task 1 - Start")
    sleep(2)
    print("Task 1 - End")
    dispatchGroup.leave()
}

dispatchGroup.enter()
DispatchQueue.global().async {
    print("Task 2 - Start")
    sleep(3)
    print("Task 2 - End")
    dispatchGroup.leave()
}

dispatchGroup.enter()
DispatchQueue.global().async {
    print("Task 3 - Start")
    sleep(1)
    print("Task 3 - End")
    dispatchGroup.leave()
}

dispatchGroup.notify(queue: .main) {
    print("All tasks completed")
}

/*
 Task 1 - Start
 Task 2 - Start
 Task 3 - Start
 Task 3 - End
 Task 1 - End
 Task 2 - End
 All tasks completed
 */


let dispatchGroup = DispatchGroup()

for i in 1...3 {
    dispatchGroup.enter()
    performTaskWithError(index: i) { error in
        if let error = error {
            print("Error occurred: \(error.localizedDescription)")
        } else {
            print("Task \(i) completed successfully")
        }
        dispatchGroup.leave()
    }
}

dispatchGroup.notify(queue: .main) {
    print("All tasks completed or failed")
}
/*
 Start task 1
 Start task 2
 Start task 3
 Task 1 completed successfully
 Error occurred: Task 2 failed
 Task 3 completed successfully
 All tasks completed or failed
 */
