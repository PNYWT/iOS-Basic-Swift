import UIKit

/*
 Struct เป็น value type
 Struct ไม่ต้องประกาศ initializer เพราะมีในตัวแล้ว จะมี argument เท่ากับ properties ให้เลยตามลำดับที่ประกาศไว้ ในกรณีที่ initial ด้วยค่าอื่นก็สามารถทำได้เลย
 Struct ถ้ามี func ที่เปลี่ยนแปลงค่าตัวแปรใน Struct ต้องประกาศ mutating
 Struct ถ้ามีการกดหนด B = A แล้ว B มีการเปลี่ยนแปลงค่า A จะไม่เปลี่ยนด้วย แสดงค่าเดิม
 Class เป็น refence type
 Class ไม่มี initializer ต้องประกาศ initializer เอง
 Class มี การอ้างอิง Instance เช่น B = A แล้ว B มีการเปลี่ยนแปลง A จะเปลี่ยนด้วย
 */
struct Position {
    var x: Int
    var y: Int

    func display() {
        print("x: \(x), y: \(y)")
    }
    
    mutating func move(to position: Position) {
        self.x = position.x
        self.y = position.y
    }
}

class Person {
    var name: String
    var age: Int

    func display() {
        print("name: \(name) age: \(age)")
    }

    init(name: String, age: Int) { //ต้องประกาศ initializer
        self.name = name
        self.age = age
    }
}

print("---------Func---------")
let firstPoint = Position(x: 0, y: 5) //struct
let detailPerson = Person(name: "John", age: 20) //class
firstPoint.display()
detailPerson.display()
print("---------End---------")

print("---------Change value---------")
var firstPoint2 = Position(x: 0, y: 5) //struct ต้องประกาศเป็น var เพื่อให้เปลี่ยนแปลงค่าใน struct
let detailPerson2 = Person(name: "John", age: 18) //class แค่ตัวแปรใน class เป็น var ก็เปลี่ยนแปลงค่าได้แล้ว
firstPoint2.x = 6
print(firstPoint2) //struct x = 0 change to x = 6
detailPerson2.name = "john"
print(detailPerson2.name) //class name "John" change to "john"
print("---------End---------")

print("---------Func Change value---------")
let origin = Position.init(x: 0, y: 0)
var firstPoint3 = Position(x: 0, y: 5) //struct
firstPoint3.move(to: origin) //mutating func move
firstPoint3.display()
print("---------End---------")

print("---------inherit---------")
//Struct
var firstPoint4 = Position(x: 1, y: 2)
var firstPoint5 = firstPoint4 // firstPoint5 จะเป็นสำเนาของ firstPoint4
firstPoint5.x = 3
firstPoint5.y = 4
firstPoint4.display()
firstPoint5.display() 
//จะเห็นว่า firstPoint5 ถูกเปลี่ยนค่า firstPoint4 ก็ยังมีค่าเดิมที่ระบุไว้ก่อนหน้า

//class
let detailPerson3 = Person(name: "HelloName", age: 20)
let detailPerson4 = detailPerson3 // detailPerson4 อ้างอิงไปยัง Instance เดียวกับ detailPerson3
detailPerson4.name = "ChangeName"
detailPerson3.display()
detailPerson4.display()
//การเปลี่ยนแปลงใน detailPerson4 จะส่งผลกระทบกับ detailPerson3
print("---------End---------")
