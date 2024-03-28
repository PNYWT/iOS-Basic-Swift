//
//  RegisterViewModel.swift
//  Basic RxSwift
//
//  Created by Dev on 28/3/2567 BE.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel:NSObject {
    
    static let AccountList = "AccountList"
    
    var usernameValid: Observable<Bool>!
    var passwordValid: Observable<Bool>!
    var emailValid: Observable<Bool>!
    var submitValid: Observable<Bool>!
    
    // Observable สำหรับการแจ้งผลลัพธ์การลงทะเบียน
    var registrationResult: PublishSubject<(Bool, StatusRegister)> = PublishSubject()
    
    init(username: Observable<String>? = nil, email: Observable<String>? = nil, password: Observable<String>? = nil) {
        super.init()
        guard let name = username, let pass = password, let mail = email else {
            return
        }
        usernameValid = name.map { $0.count >= 8 && $0.count <= 16 }
        passwordValid = pass.map { $0.count >= 12 && $0.count <= 20 && self.checkStrongPassword(password: $0) }
        emailValid = mail.map { $0.contains("@") && $0.contains(".") }
        
        submitValid = Observable.combineLatest(usernameValid!, emailValid!, passwordValid!) { $0 && $1 && $2 }
    }
    
    public func checkAndSaveAccount(username: String, password: String, email: String) -> Observable<StatusRegister> {
        return Observable.create { observer in
            self.haveAccountInList(username: username, password: password, email: email) { status, withError in
                if status {
                    observer.onNext(.Success)
                    observer.onCompleted()
                } else {
                    observer.onError(withError)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    private func checkStrongPassword(password:String)-> Bool {
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_+=-[]{};:'\",.<>/?\\|`~")
        let digitCharacterSet = CharacterSet.decimalDigits
        let passwordHasSpecialCharacter = password.rangeOfCharacter(from: specialCharacterSet) != nil
        let passwordHasDigit = password.rangeOfCharacter(from: digitCharacterSet) != nil
        return passwordHasSpecialCharacter && passwordHasDigit
    }
    
    private func haveAccountInList(username:String, password:String, email:String, completionCheck:((_ status:Bool, _ withError:StatusRegister)->Void))->Void {
        
        guard let dataAccount = UserDefaults.standard.data(forKey: RegisterViewModel.AccountList) else {
            saveNewAccount(newusername: username, password: password, email: email, oldListAccount: nil) { status, withError in
                completionCheck(status, withError)
            }
            return
        }
        
        guard let listAccount = try? JSONDecoder().decode([AllAccountModel].self, from: dataAccount) else{
            completionCheck(false, .FailJSONDecoder)
            return
        }
        
        if listAccount.contains(where: { $0.username == username }) {
            completionCheck(false, .FailAlreadyhaveAccount)
        }else {
            saveNewAccount(newusername: username, password: password, email: email, oldListAccount: listAccount) { status, withError in
                completionCheck(status, withError)
            }
        }
    }
    
    private func saveNewAccount(newusername:String, password:String, email:String ,oldListAccount:[AllAccountModel]?, completionSave:((_ status:Bool, _ withError:StatusRegister)->Void))->Void {
        
        let newUserAccount = AllAccountModel(username: newusername, password: password, email: email)
        
        if var haveOldListAccount = oldListAccount, haveOldListAccount.count > 0 {
            haveOldListAccount.append(newUserAccount)
            guard let encoder = try? JSONEncoder().encode(haveOldListAccount) else {
                completionSave(false, .FailJSONEncoder)
                return
            }
            UserDefaults.standard.setValue(encoder, forKey: RegisterViewModel.AccountList)
            completionSave(true, .Success)
        } else {
            guard let encoder = try? JSONEncoder().encode([newUserAccount]) else {
                completionSave(false, .FailJSONEncoder)
                return
            }
            UserDefaults.standard.setValue(encoder, forKey: RegisterViewModel.AccountList)
            completionSave(true, .Success)
        }
    }
    
    public func removeAccount() -> Observable<Void> {
        return Observable.create { observer in
            UserDefaults.standard.removeObject(forKey: RegisterViewModel.AccountList)
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create {}
        }
    }
}

extension Reactive where Base: UITextField {
    var isValid: Binder<Bool> {
        return Binder(self.base) { textField, isValid in
            textField.textColor = isValid ? .black : .red
        }
    }
}

