/*
 Use Case: การดาวน์โหลดไฟล์ทีละไฟล์ เช่น การโหลดข้อมูลจากเซิร์ฟเวอร์ทีละ endpoint เพื่อหลีกเลี่ยงการทำงานพร้อมกันที่อาจเกิดข้อผิดพลาด
 */
import Foundation

func downloadFilesInOrder() {
    let serialQueue = DispatchQueue(label: "com.example.serialQueue")
    
    serialQueue.async {
        print("Start downloading file 1")
        sleep(2) // จำลองการดาวน์โหลด
        print("Finished downloading file 1")
    }
    
    serialQueue.async {
        print("Start downloading file 2")
        sleep(3) // จำลองการดาวน์โหลด
        print("Finished downloading file 2")
    }
    
    serialQueue.async {
        print("Start downloading file 3")
        sleep(1) // จำลองการดาวน์โหลด
        print("Finished downloading file 3")
    }
    
    print("Tasks are queued, execution will follow FIFO order")
}

downloadFilesInOrder()

/*
 Tasks are queued, execution will follow FIFO order
 Start downloading file 1
 Finished downloading file 1
 Start downloading file 2
 Finished downloading file 2
 Start downloading file 3
 Finished downloading file 3

 */
