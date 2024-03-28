//
//  TextFieldVC.swift
//  Basic RxSwift and Alamofire
//
//  Created by Dev on 28/3/2567 BE.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var loginViewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.rx.text.orEmpty.bind(to: loginViewModel.username).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: loginViewModel.password).disposed(by: disposeBag)
        
        loginViewModel.isValid().bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        loginViewModel.isValid().map { $0 ? 1.0 : 0.5 }.bind(to: loginButton.rx.alpha).disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { _ in
                print("Login Success")
            }).disposed(by: disposeBag)
    }
}
