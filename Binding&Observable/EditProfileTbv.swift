//
//  EditProfileTbv.swift
//
//  Created by Dev on 9/4/2567 BE.
//

import Foundation
import UIKit

class EditProfileTbv: UITableView {
    
    private lazy var headerUserChangeImage: HeaderUserChangeImage = {
        let view = HeaderUserChangeImage(frame: .zero)
        return view
    }()
    private var editProfileVC: EditProfileVM = EditProfileVM()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = .clear
        self.register(UINib(nibName: "EditProfileViewCell", bundle: nil), forCellReuseIdentifier: EditProfileViewCell.indetifierCell)
        self.alpha = 0
        self.tableHeaderView = headerUserChangeImage
        editProfileVC.setupBindData(tbv: self, withHeader: headerUserChangeImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerUserChangeImage.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 200)
    }
    
    public func loadProfile() {
        editProfileVC.loadProfileNow(firstSet: true)
    }
}

extension EditProfileTbv: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileViewCell.indetifierCell, for: indexPath) as! EditProfileViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.delegate = self
        cell.configForName(nameUser: ConfigAccount.shared.user_name)
        return cell
    }
}

extension EditProfileTbv: EditProfileViewCellDelegate {
    func didSelectEditName() {
        print("didSelectEditName Working")
        editProfileVC.presentAlertChangeName(mainContent: self)
    }
}
