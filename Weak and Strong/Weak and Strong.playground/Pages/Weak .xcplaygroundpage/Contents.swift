//: [Previous](@previous)

import Foundation

class Person {
    var name: String

    init(name: String) {
        self.name = name
    }

    weak var company: Company?
}

class Company {
    var employee: Person?

    init(employee: Person?) {
        self.employee = employee
    }
}

// Create a person object
let john = Person(name: "John Doe")

// Create a company object
let company = Company(employee: john)

// Set the weak reference
john.company = company

// Break the strong reference
company.employee = nil

// Now both john and company can be deallocated when no strong references remain

// Weak Reference: ไม่เพิ่ม reference count ของ object. ใช้เพื่อหลีกเลี่ยง retain cycles. เมื่อ object ที่ถูกอ้างอิงถูกทำลาย weak reference จะถูกตั้งค่าเป็น nil.
