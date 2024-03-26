//
//  RegisterVC.swift
//  ProjectSoftwareTest
//
//  Created by CallmeOni on 10/3/2567 BE.
//

import UIKit

class RegisterVC: UIViewController {
    
    lazy var lbTitleRegister:UILabel! = {
        let lb = UILabel(frame: .zero)
        lb.font = .boldSystemFont(ofSize: 24)
        lb.text = "Register"
        lb.textColor = .systemBlue
        lb.textAlignment = .center
        return lb
    }()

    lazy var usernameRegister: UITextField! = {
        let textField = UITextField(frame: .zero)
        textField.accessibilityIdentifier = "usernameTextField"
        textField.placeholder = "Input 8-16 characters."
        textField.borderStyle = .line
        textField.textContentType = .name
        textField.withImage(direction: .Left, image: UIImage(systemName: "person.circle")!, colorSeparator: .clear, colorBorder: .clear)
        textField.delegate = self
        return textField
    }()
    
    lazy var passwordRegister: UITextField! = {
        let textField = UITextField(frame: .zero)
        textField.accessibilityIdentifier = "passwordTextField"
        textField.placeholder = "Input 12-20 characters."
        textField.borderStyle = .line
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        textField.withImage(direction: .Left, image: UIImage(systemName: "lock.circle")!, colorSeparator: .clear, colorBorder: .clear)
        textField.delegate = self
        return textField
    }()
    
    lazy var cPasswordRegister: UITextField! = {
        let textField = UITextField(frame: .zero)
        textField.accessibilityIdentifier = "cPasswordTextField"
        textField.placeholder = "Input password again."
        textField.borderStyle = .line
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        textField.withImage(direction: .Left, image: UIImage(systemName: "lock.circle")!, colorSeparator: .clear, colorBorder: .clear)
        textField.delegate = self
        return textField
    }()
    
    lazy var registerButton: UIButton! = {
        let btn = UIButton(frame: .zero)
        btn.accessibilityIdentifier = "confirmButton"
        btn.setTitle("Register now", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(actionRegister(_:)), for: .touchUpInside)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private var registerManager = Register()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupEvent()
    }
    
    private func setupView(){
        view.backgroundColor = .lightGray
        view.addSubview(lbTitleRegister)
        view.addSubview(usernameRegister)
        view.addSubview(passwordRegister)
        view.addSubview(cPasswordRegister)
        view.addSubview(registerButton)
        let tabScreen = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tabScreen)
    }
    
    private func setupEvent(){
        registerManager.alertAlert = { messageError in
            let alert = UIAlertController(title: nil, message: messageError.rawValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.registerButton.isEnabled = true
                if messageError == .Success {
                    self.usernameRegister.text = nil
                    self.passwordRegister.text = nil
                    self.cPasswordRegister.text = nil
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lbTitleRegister.frame = CGRect(x: (view.frame.width - (view.frame.width * 0.75))/2, y: view.safeAreaInsets.top + 100, width: view.frame.width * 0.75, height: 25)
        
        usernameRegister.frame = CGRect(x: lbTitleRegister.frame.origin.x, y: lbTitleRegister.frame.origin.y + 75 + 16, width: lbTitleRegister.frame.width, height: 75)
        
        passwordRegister.frame = CGRect(x: usernameRegister.frame.origin.x, y: usernameRegister.frame.origin.y + 75 + 16, width: usernameRegister.frame.width, height: 75)
        
        cPasswordRegister.frame = CGRect(x: passwordRegister.frame.origin.x, y: passwordRegister.frame.origin.y + 75 + 16, width: passwordRegister.frame.width, height: 75)
        
        registerButton.frame = CGRect(x: (view.frame.width - 150)/2, y: cPasswordRegister.frame.origin.y + cPasswordRegister.frame.height + 16, width: 150, height: 50)
        
    }
    
    @objc func actionRegister(_ sender: UIButton) {
        sender.isEnabled = false
        registerManager.createAccount(username: usernameRegister.text, password: passwordRegister.text, confirmPassword: cPasswordRegister.text)
    }
    
    @objc private func closeKeyboard(){
        view.endEditing(true)
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameRegister {
            usernameRegister.text = nil
        } else if textField == passwordRegister {
            passwordRegister.text = nil
        } else if textField == cPasswordRegister {
            cPasswordRegister.text = nil
        }
    }
}
