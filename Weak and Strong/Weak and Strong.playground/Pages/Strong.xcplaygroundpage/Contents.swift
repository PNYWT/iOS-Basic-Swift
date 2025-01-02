import UIKit

class Person {
    var name: String

    init(name: String) {
        self.name = name
    }
}

class Company {
    var employee: Person?

    init(employee: Person?) {
        self.employee = employee
    }
}

// Create a person object
let john = Person(name: "John Doe")

// Create a company object with a strong reference to the person
let company = Company(employee: john)

// John will not be deallocated until the company and any other strong references are nil

// Strong Reference: เพิ่ม reference count ของ object. Object จะไม่ถูกทำลายตราบใดที่ยังมี strong references.
