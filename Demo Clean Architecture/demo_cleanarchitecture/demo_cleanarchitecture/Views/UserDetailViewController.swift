//
//  UserDetailViewController.swift
//  demo_cleanarchitecture
//
//  Created by CallmeOni on 26/2/2568 BE.
//

import UIKit

final class UserDetailViewController: UIViewController {
    private let user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        let nameLabel = UILabel()
        nameLabel.text = "Name: \(user.name)"
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)

        let emailLabel = UILabel()
        emailLabel.text = "Email: \(user.email)"
        emailLabel.textAlignment = .center
        emailLabel.font = .systemFont(ofSize: 16)

        let stackView = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

