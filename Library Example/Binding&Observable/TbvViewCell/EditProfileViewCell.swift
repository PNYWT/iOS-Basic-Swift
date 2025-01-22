//
//  EditProfileViewCell.swift
//
//  Created by Dev on 9/4/2567 BE.
//

import UIKit

protocol EditProfileViewCellDelegate: NSObject {
    func didSelectEditName()
}

class EditProfileViewCell: UITableViewCell {
    
    weak var delegate: EditProfileViewCellDelegate?
    
    static let indetifierCell = "EditProfileViewCell"
    
    private lazy var titleRowLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Language.getLocalLanguage(string: "me_name")
        label.setupBasicLabel(numberOfLines: 1, textColor: .white, whatFont: .PromptRegular, whatSize: 18)
        return label
    }()
    
    private lazy var btnChangeName: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.setupBasicLabel(numberOfLines: 1, textColor: .white, whatFont: .PromptRegular, whatSize: 16)
        btn.addTarget(self, action: #selector(selectBtnChangeName), for: .touchUpInside)
        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(titleRowLabel)
        addSubview(btnChangeName)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleRowLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        titleRowLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        titleRowLabel.heightAnchor.constraint(equalToConstant: titleRowLabel.font.pointSize).isActive = true
        
        btnChangeName.leadingAnchor.constraint(lessThanOrEqualTo: titleRowLabel.trailingAnchor, constant: 4).isActive = true
        btnChangeName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        btnChangeName.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
    }
    
    public func configForName(nameUser: String?) {
        titleRowLabel.text = Language.getLocalLanguage(string: "me_name")
        btnChangeName.setTitle(nameUser ?? "", for: .normal)
    }
}

extension EditProfileViewCell {
    @objc private func selectBtnChangeName() {
        delegate?.didSelectEditName()
    }
}
