//
//  SectionTbvViewController.swift
//  Core Data QuickStart Tutorial
//
//  Created by Dev on 10/6/2567 BE.
//

import UIKit
import CoreData
import SnapKit

class SectionTbvViewController: UIViewController {
    
    private lazy var tbv: UITableView = {
        let tbv = UITableView(frame: .zero, style: .plain)
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    
    private var context: NSManagedObjectContext {
        return AppDelegate.shared.persistentContainer.viewContext
    }
    
    private var contextSave: Bool? {
        set (new) {
            if new ?? false {
                AppDelegate.shared.saveContext()
                DispatchQueue.main.async {
                    self.tbv.reloadData()
                }
            }
        }
        get {
            return nil
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Person>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeFetchedResultsController()
        addSampleData() // เพิ่มบรรทัดนี้หากต้องการเพิ่มข้อมูลตัวอย่าง
    }
    
    private func setupUI() {
        view.backgroundColor = .gray
        view.layoutIfNeeded()
        view.addSubview(tbv)
        tbv.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.trailing.equalTo(view.snp.trailing)
            make.leading.equalTo(view.snp.leading)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: "family.name", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: "family.name",
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch entities: \(error)")
        }
    }
    
    func addSampleData() {
        let family1 = Family(context: context)
        family1.name = "CallmeOni Family"
        
        let person1 = Person(context: context)
        person1.name = "Oni"
        person1.age = 28
        person1.gender = "Male"
        person1.family = family1
        
        let family2 = Family(context: context)
        family2.name = "Smith Family"
        
        let person2 = Person(context: context)
        person2.name = "John"
        person2.age = 35
        person2.gender = "Male"
        person2.family = family2
        
        contextSave = true
        
    }
}

extension SectionTbvViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = person.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
}

extension SectionTbvViewController: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tbv.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tbv.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tbv.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tbv.cellForRow(at: indexPath)
                let person = fetchedResultsController.object(at: indexPath)
                cell?.textLabel?.text = person.name
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tbv.deleteRows(at: [indexPath], with: .automatic)
                tbv.insertRows(at: [newIndexPath], with: .automatic)
            }
        @unknown default:
            fatalError("Unknown case in NSFetchedResultsController")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tbv.endUpdates()
    }
}
