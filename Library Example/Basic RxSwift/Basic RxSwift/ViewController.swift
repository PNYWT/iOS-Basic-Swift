//
//  ViewController.swift
//  Basic RxSwift
//
//  Created by Dev on 27/3/2567 BE.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private lazy var tbv:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        return table
    }()
    
    private var dataProduct:[Product] = []
    
    private var viewModel:ProductViewModel!
    
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tbv)
        regisEvent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tbv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tbv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    private func regisEvent() {
        viewModel = ProductViewModel()
        
        //Binding Data to Tableview
        viewModel.items
            .observe(on: MainScheduler.instance)
            .bind(to: tbv.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, product, cell) in
                cell.textLabel?.text = product.title
                cell.imageView?.image = UIImage(systemName: product.imageName)
            }
            .disposed(by: bag)
        
        //for viewModel.fetchItemsByService()
       /*
        viewModel.items
            .observe(on: MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                let message: String
                if let myError = error as? MyError {
                    message = myError.message
                } else {
                    message = "An error occurred: \(error.localizedDescription)"
                }
                self?.showErrorMessage(message)
            })
            .disposed(by: bag)
        */

        //action table
        tbv.rx.modelSelected(Product.self).bind { model in
            print("User Select Product at -> \(model.title)")
        }.disposed(by: bag)
        
        tbv.rx.itemSelected.bind { item in
            print("User Select Product at IndexPath -> \(item)")
        }.disposed(by: bag)
        
        viewModel.fetchItems()
//        viewModel.fetchItemsByService()
    }
    
    private func showErrorMessage(_ message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
}

