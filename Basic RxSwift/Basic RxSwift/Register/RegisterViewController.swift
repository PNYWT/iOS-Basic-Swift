//
//  RegisterViewController.swift
//  Basic RxSwift
//
//  Created by Dev on 28/3/2567 BE.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
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
        textField.placeholder = "Input 8-16 characters."
        textField.borderStyle = .line
        textField.textContentType = .name
        textField.withImage(direction: .Left, image: UIImage(systemName: "person.circle")!, colorSeparator: .clear, colorBorder: .clear)
        textField.delegate = self
        return textField
    }()
    
    lazy var passwordRegister: UITextField! = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Input 12-20 characters."
        textField.borderStyle = .line
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        textField.withImage(direction: .Left, image: UIImage(systemName: "lock.circle")!, colorSeparator: .clear, colorBorder: .clear)
        textField.delegate = self
        return textField
    }()
    
    lazy var emailRegister: UITextField! = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Input Email."
        textField.borderStyle = .line
        textField.textContentType = .emailAddress
        textField.withImage(direction: .Left, image: UIImage(systemName: "mail")!, colorSeparator: .clear, colorBorder: .clear)
        textField.delegate = self
        return textField
    }()
    
    lazy var registerButton: UIButton! = {
        let btn = UIButton(frame: .zero)
        btn.setTitle("Register now", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    let disposeBag = DisposeBag()
    private var registerManager:RegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.value(forKey: RegisterViewModel.AccountList) {
            ConfigApp.initWindows(isGoMain: true)
            return
        }
    }
    
    private func setupView(){
        view.backgroundColor = .lightGray
        view.addSubview(lbTitleRegister)
        view.addSubview(usernameRegister)
        view.addSubview(passwordRegister)
        view.addSubview(emailRegister)
        view.addSubview(registerButton)
        let tabScreen = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tabScreen)
    }
    
    private func setupEvent() {
        
        //Setup Observable
        registerManager = RegisterViewModel.init(username: usernameRegister.rx.text.orEmpty.asObservable(), email: emailRegister.rx.text.orEmpty.asObservable(), password: passwordRegister.rx.text.orEmpty.asObservable())
        
        //Bind Variable UI to Observable
        registerManager.usernameValid?.bind(to: usernameRegister.rx.isValid).disposed(by: disposeBag)
        registerManager.passwordValid?.bind(to: passwordRegister.rx.isValid).disposed(by: disposeBag)
        registerManager.emailValid?.bind(to: emailRegister.rx.isValid).disposed(by: disposeBag)
        registerManager.submitValid?.bind(to: registerButton.rx.isEnabled).disposed(by: disposeBag)
        
        //Setup Action Button
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("registerButton Working")
                guard let self = self else { return }
                        let username = self.usernameRegister.text ?? ""
                        let password = self.passwordRegister.text ?? ""
                        let email = self.emailRegister.text ?? ""
                        
                        self.registerManager.checkAndSaveAccount(username: username, password: password, email: email)
                            .observe(on: MainScheduler.instance)
                            .subscribe {  event in
                                switch event {
                                case .next(let status):
                                    switch status {
                                    case .Success:
                                        self.showAlert(message: status.rawValue).subscribe(onNext: { _ in
                                            ConfigApp.initWindows(isGoMain: true)
                                        }).disposed(by: self.disposeBag)
                                    case .FailJSONDecoder, .FailJSONEncoder:
                                        self.showAlert(message: status.rawValue).subscribe(onNext: { _ in
                                            return
                                        }).disposed(by: self.disposeBag)
                                    case .FailAlreadyhaveAccount:
                                        self.showAlert(message: status.rawValue).subscribe(onNext: { _ in
                                            return
                                        }).disposed(by: self.disposeBag)
                                    }
                                case .error(let error):
                                    print("An error occurred: \(error)")
                                    // Handle observable error
                                default:
                                    break
                                }
                            }
                            .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lbTitleRegister.frame = CGRect(x: (view.frame.width - (view.frame.width * 0.75))/2, y: view.safeAreaInsets.top + 100, width: view.frame.width * 0.75, height: 25)
        
        usernameRegister.frame = CGRect(x: lbTitleRegister.frame.origin.x, y: lbTitleRegister.frame.origin.y + 75 + 16, width: lbTitleRegister.frame.width, height: 75)
        
        passwordRegister.frame = CGRect(x: usernameRegister.frame.origin.x, y: usernameRegister.frame.origin.y + 75 + 16, width: usernameRegister.frame.width, height: 75)
        
        emailRegister.frame = CGRect(x: passwordRegister.frame.origin.x, y: passwordRegister.frame.origin.y + 75 + 16, width: passwordRegister.frame.width, height: 75)
        
        registerButton.frame = CGRect(x: (view.frame.width - 150)/2, y: emailRegister.frame.origin.y + emailRegister.frame.height + 16, width: 150, height: 50)
        
    }
    
    @objc private func closeKeyboard(){
        view.endEditing(true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameRegister {
            usernameRegister.text = nil
        } else if textField == passwordRegister {
            passwordRegister.text = nil
        } else if textField == emailRegister {
            emailRegister.text = nil
        }
    }
}
