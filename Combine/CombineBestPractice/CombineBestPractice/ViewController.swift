//
//  ViewController.swift
//  CombineBestPractice
//
//  Created by Dev on 2/1/2568 BE.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var currentValueViewModel = CurrentValueSubjectViewModelExample()
    private var eventViewModel = EventViewModelExample()
    private var futureViewModel = FutureViewModelExample()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var lbShowResult: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }

    private func setupUI() {
        view.addSubview(lbShowResult)
    }

    
    private func setupBinding() {
        
        // MARK: CurrentValue
        currentValueViewModel.userName
            .sink { [weak self] name in
                self?.lbShowResult.text = "User Name: \(name)"
            }
            .store(in: &cancellables)
        
        // MARK: EventViewModel
        eventViewModel.buttonTapped
            .sink { [weak self] in
                self?.lbShowResult.text = "Button was tapped!"
            }
            .store(in: &cancellables)
        
        // MARK: Future
        futureViewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (users: [User]) in
                // ระบุประเภทของ users อย่างชัดเจน
                // reloadData()
            }
            .store(in: &cancellables)
        
        futureViewModel.$isRefreshing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isRefreshing: Bool) in
                // ระบุประเภทของ isRefreshing อย่างชัดเจน
                if !isRefreshing {
                    // endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func actionTabButton(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            currentValueViewModel.fetchUserName()
        case 1:
            futureViewModel.toggleRefresh()
        case 2:
            eventViewModel.buttonWasTapped()
        default:
            break
        }
    }
}




