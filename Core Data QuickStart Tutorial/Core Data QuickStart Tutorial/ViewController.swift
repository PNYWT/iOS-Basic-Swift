//
//  ViewController.swift
//  Core Data QuickStart Tutorial
//
//  Created by Dev on 10/6/2567 BE.
//

import UIKit
import SnapKit
import CoreData

class ViewController: UIViewController {
    
    private lazy var lookSectionFamily: UIButton = {
        let btn = UIButton()
        btn.tintColor = .red
        btn.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(gotoSection), for: .touchUpInside)
        return btn
    }()

    private lazy var addButtn: UIButton = {
        let btn = UIButton()
        btn.tintColor = .red
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(addDataPerson), for: .touchUpInside)
        return btn
    }()
    
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
            }
        }
        get {
            return nil
        }
    }
    
    private var itemsPerson: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        fetchPeople()
//        fetchRelationshitp()
    }
    
    private func fetchRelationshitp() {
        let newFamily = Family(context: context)
        newFamily.name = "Oni"

        let newPerson = Person(context: context)
        newPerson.name = "CallmeOni"
        newPerson.age = 28
        newPerson.gender = "Male"
        newPerson.family = newFamily

        contextSave = true
        fetchPeople()
    }
    
    private func fetchPeople() {
        do {
            let request = Person.fetchRequest()
            
            /*
             // set filtering and sorting request
             let pred = NSPredicate(format: "name CONTAINS %@", "Ted")
             request.predicate = pred
             
             let sort = NSSortDescriptor(key: "name", ascending: true)
             request.sortDescriptors = [sort]
             */
            
            self.itemsPerson = try context.fetch(request)
            DispatchQueue.main.async { [weak self] in
                self?.tbv.reloadData()
            }
        } catch {
            
        }
    }
    
    private func setupUI() {
        view.addSubview(addButtn)
        view.addSubview(lookSectionFamily)
        view.addSubview(tbv)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.trailing.equalTo(view.snp.trailingMargin)
        }
        
        lookSectionFamily.snp.makeConstraints { make in
            make.centerY.equalTo(addButtn.snp.centerY)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.leading.equalTo(view.snp.leading)
        }
        
        tbv.snp.makeConstraints { make in
            make.top.equalTo(addButtn.snp.bottom)
            make.trailing.equalTo(view.snp.trailing)
            make.leading.equalTo(view.snp.leading)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    @objc private func gotoSection() {
        let vc = SectionTbvViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func addDataPerson() {
        let alert = UIAlertController(title: "Add Data Person", message: "Input Name", preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Add Now", style: .default, handler: { _ in
            guard let textfield = alert.textFields?[0], !(textfield.text?.isEmpty ?? true) else {
                return
            }
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            self.contextSave = true
            self.fetchPeople()
        }))
        
        self.present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsPerson.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = String(format: "name %@, family %@", itemsPerson[indexPath.row].name ?? "", itemsPerson[indexPath.row].family?.name ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Person", message: "Edit Name", preferredStyle: .alert)
        alert.addTextField()
        let textfield = alert.textFields?[0]
        textfield?.text = self.itemsPerson[indexPath.row].name
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textfield = alert.textFields?[0], !(textfield.text?.isEmpty ?? true) else {
                return
            }
            self.itemsPerson[indexPath.row].name = textfield.text
            self.contextSave = true
            self.fetchPeople()
        }
        
        alert.addAction(saveButton)
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completeionHandle in
            self.context.delete(self.itemsPerson[indexPath.row])
            self.contextSave = true
            self.fetchPeople()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

