//
//  Family+CoreDataProperties.swift
//  
//
//  Created by Dev on 10/6/2567 BE.
//
//

import Foundation
import CoreData

extension Family {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Family> {
        return NSFetchRequest<Family>(entityName: "Family")
    }

    @NSManaged public var name: String?
    @NSManaged public var people: Person?

    // MARK: Generated accessors for people
    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Person)
    
    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Person)
    
    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSSet)
    
    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSSet)
}
