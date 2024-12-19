//
//  ViewController.swift
//  OpenAIChatDemo
//
//  Created by Dev on 16/12/2567 BE.
//

import UIKit
import SnapKit
import OpenAISwift

class ViewController: UIViewController {
    
    private lazy var fieldText: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ask Question..."
        textField.backgroundColor = .darkGray
        textField.textColor = .white
        textField.delegate = self
        return textField
    }()
    
    private lazy var tableChat: UITableView = {
        let tableView = UITableView()
        tableView.register(DynamicLabelCell.self, forCellReuseIdentifier: DynamicLabelCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .lightGray
        return tableView
    }()
    
    private var openAICaller = OpenAICaller()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.addSubview(fieldText)
        fieldText.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32.0)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.height.equalTo(50.0)
        }
        
        view.addSubview(tableChat)
        tableChat.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(fieldText.snp.top)
        }
        
        openAICaller.prepareChat()
        DispatchQueue.main.async { [weak self] in
            self?.tableChat.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openAICaller.chatUIHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DynamicLabelCell.reuseIdentifier) as? DynamicLabelCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(with: openAICaller.chatUIHistory[indexPath.row])
        return cell
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let haveText = textField.text, !haveText.isEmpty {
            openAICaller.getReponse(input: haveText) { [weak self] (resultChat: Result<Bool, Error>)  in
                switch resultChat {
                case .success(_):
                    print("Request Success")
                    DispatchQueue.main.async {
                        self?.tableChat.reloadData()
                        self?.fieldText.text = nil
                    }
                case .failure(let failure):
                    print("Fail -> \(failure.localizedDescription)")
                }
            }
        }
        return true
    }
}

