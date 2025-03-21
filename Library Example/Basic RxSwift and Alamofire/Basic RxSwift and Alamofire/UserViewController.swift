//
//  ViewController.swift
//  Basic RxSwift and Alamofire
//
//  Created by Dev on 28/3/2567 BE.
//

import UIKit
import RxSwift
import RxCocoa

class UserViewController: UIViewController {
    private var userViewModel = UserViewModel()
    private var disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView! = {
        let tbv = UITableView()
        tbv.backgroundColor = .cyan
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupTableView()
        setupNav()
        bindUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    private func setupNav() {
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshUserData))
        navigationItem.leftBarButtonItem = refreshButton
        
        let goTextField = UIBarButtonItem(title: "TextField", style: .plain, target: self, action: #selector(goTextFieldPage))
        navigationItem.rightBarButtonItem = goTextField
    }
    
    @objc private func refreshUserData() {
        userViewModel.fetchUserData()
    }
    
    @objc private func goTextFieldPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func bindUserData() {
        userViewModel.usersData.bind(to: tableView.rx.items(cellIdentifier: "UserCell", cellType: UITableViewCell.self)) { (row, user, cell) in
            cell.textLabel?.text = "\(user.name) - \(user.email)"
        }.disposed(by: disposeBag)
        
        userViewModel.fetchUserData()
    }
}
