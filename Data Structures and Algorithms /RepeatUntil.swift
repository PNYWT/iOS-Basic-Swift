/*
ระบบการบันทึกข้อมูลการขายสินค้า
สถานการณ์: ธุรกิจที่มีการขายสินค้าและต้องบันทึกยอดขายทีละรายการ ซึ่งต้องรับราคาสินค้าจากผู้ขายและคำนวณผลรวม
การปรับใช้: ปรับโค้ดเพื่อรับข้อมูลราคาสินค้าแต่ละชิ้นจากผู้ขาย และคำนวณยอดขายทั้งหมดของวันนั้น
*/

import Foundation

var totalSales: Int = 0
let numberOfItems: Int = 3

for item: Int in 1...numberOfItems {
    var itemPrice: Int
    repeat {
        print("กรุณากรอกราคาสินค้า (ชิ้นที่ \(item))")
        if let input: String = readLine(), let price: Int = Int(input), price > 0 {
            itemPrice = price
            totalSales += itemPrice
        } else {
            print("กรุณากรอกจำนวนเงินที่เป็นบวก")
            continue
        }
        break
    } while true
}

print("ยอดขายรวมวันนี้: \(totalSales) บาท")

