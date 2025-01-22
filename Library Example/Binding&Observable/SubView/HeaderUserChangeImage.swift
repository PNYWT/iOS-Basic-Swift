//
//  HeaderUserChangeImage.swift
//
//  Created by Dev on 9/4/2567 BE.
//

import Foundation
import UIKit

class HeaderUserChangeImage: UIView {
    
    var forceUpdateProfile: Observable<Bool> = Observable(value: nil)
    /*
     ตัวนี้ระหว่างหน่อยเรียกใช้ใน HeaderUserChangeImageVM กับ EditProfileVM ใช้บังคับ update ค่า is_review_profile หลัง upload image ผ่านแล้ว
     Flow: HeaderUserChangeImageVM ยิง upload ผ่าน -> สั่ง forceUpdateProfile true -> Bind ใน EditProfileVM ทำงาน สั่ง forceUpdateProfile false แล้วสั่ง request profile ใหม่เพื่อ update ค่า
     */
    
    private lazy var imageUser: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var btnChangeImageUser: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "camera.circle"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(selectPhotoToChange(sender:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lbUserID : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setupBasicLabel(numberOfLines: 1, textAlignment: .center, textColor: .lightGray, whatFont: .PromptRegular, whatSize: 14)
        return label
    }()
    
    private lazy var lbProcess : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setupBasicLabel(numberOfLines: 1, textAlignment: .center, textColor: .lightGray, whatFont: .PromptBold, whatSize: 14)
        label.isHidden = true
        return label
    }()
    
    private var headerUserVM = HeaderUserChangeImageVM()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        addSubview(imageUser)
        addSubview(btnChangeImageUser)
        addSubview(lbUserID)
        imageUser.addSubview(lbProcess)
        headerUserVM = HeaderUserChangeImageVM(mainContent: self, withImageUI: imageUser)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageUser.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        imageUser.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        imageUser.heightAnchor.constraint(equalToConstant: self.frame.height * 0.80).isActive = true
        imageUser.widthAnchor.constraint(equalTo: imageUser.heightAnchor, multiplier: 1.0).isActive = true
        imageUser.makeCornerRadius(radius: imageUser.frame.height/2.0) 
        
        lbProcess.centerXAnchor.constraint(equalTo: imageUser.centerXAnchor).isActive = true
        lbProcess.bottomAnchor.constraint(equalTo: imageUser.bottomAnchor).isActive = true
        lbProcess.heightAnchor.constraint(equalToConstant: imageUser.frame.height).isActive = true
        lbProcess.widthAnchor.constraint(equalToConstant: imageUser.frame.width).isActive = true
        
        btnChangeImageUser.centerYAnchor.constraint(equalTo: imageUser.bottomAnchor, constant: -40/2).isActive = true
        btnChangeImageUser.centerXAnchor.constraint(equalTo: imageUser.trailingAnchor, constant: -40/2).isActive = true
        btnChangeImageUser.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnChangeImageUser.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lbUserID.centerXAnchor.constraint(equalTo: imageUser.centerXAnchor, constant: 0).isActive = true
        lbUserID.topAnchor.constraint(equalTo: imageUser.bottomAnchor, constant: 0).isActive = true
        lbUserID.heightAnchor.constraint(equalToConstant: self.frame.height * 0.15).isActive = true
        lbUserID.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
    }
    
    @objc private func selectPhotoToChange(sender: UIButton) {
        sender.isEnabled = false
        headerUserVM.actionChangeImage(sender: sender)
    }
    
    public func setupHeaderView() {
        if ConfigAccount.shared.is_review_profile == "0" {
            imageUser.sd_setImage(with: URL(string: ConfigAccount.shared.user_logo), completed: nil)
            headerUserVM.imageManager.deleteLocalImageCopyNow()
            lbProcess.isHidden = true
        } else {
            imageUser.sd_setImage(with: ConfigAccount.shared.user_logo_LocalPath, completed: nil)
            lbProcess.isHidden = false
        }
        lbUserID.text = String(format: "ID: %@", ConfigAccount.shared.user_id!)
    }
}
