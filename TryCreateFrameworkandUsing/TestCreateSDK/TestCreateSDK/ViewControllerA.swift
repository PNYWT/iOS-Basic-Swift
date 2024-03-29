//
//  ViewControllerA.swift
//  TestCreateSDK
//
//  Created by CallmeOni on 19/3/2567 BE.
//

import UIKit

public class ViewControllerA: UIViewController {

    private lazy var tableView:UITableView! = {
        let tbv = UITableView(frame: .zero)
        tbv.register(UINib(nibName: "HelloTableViewCell", bundle: Bundle(for: HelloTableViewCell.self)), forCellReuseIdentifier: HelloTableViewCell.identifier)
        tbv.dataSource = self
        tbv.delegate = self
        tbv.translatesAutoresizingMaskIntoConstraints = false
        return tbv
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(tableView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            tableView.heightAnchor.constraint(equalToConstant: view.frame.height - self.view.safeAreaInsets.top),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        ])
    }
}

extension ViewControllerA : UITableViewDelegate, UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HelloTableViewCell.identifier, for: indexPath) as! HelloTableViewCell
        cell.configContentCell(hello: "Hello :", indexPath: indexPath)
        return cell
    }
}
