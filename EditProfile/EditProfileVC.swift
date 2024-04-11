//
//  EditProfileVC.swift
//  PlayPlayPlus
//
//  Created by Dev on 9/4/2567 BE.
//

import UIKit

class EditProfileVC: UIViewController {
    
    var eventChangeName: (() -> Void)?
    
    private lazy var editProfileTbv: EditProfileTbv = {
        let tbv = EditProfileTbv(frame: .zero, style: .plain)
        return tbv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
    }
    
    private func setupContentView() {
        view.addSubview(editProfileTbv)
        editProfileTbv.loadProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editProfileTbv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        editProfileTbv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        editProfileTbv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        editProfileTbv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}
