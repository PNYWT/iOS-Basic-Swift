//
//  Register.swift
//  ProjectSoftwareTest
//
//  Created by CallmeOni on 10/3/2567 BE.
//

import Foundation

class Register:NSObject{
    
    static let AccountList = "AccountList"
    var alertAlert:((_ messageError:StatusRegister)->Void)?
    
    func createAccount(username:String?, password:String?, confirmPassword:String?) {
        
        guard let userRegister = username, userRegister.count > 0 else {
            alertAlert?(.FailUsernameEmpty)
            return
        }
        
        guard let pwd = password, pwd.count > 0 else {
            alertAlert?(.FailPasswordEmpty)
            return
        }
        
        guard let cPwd = confirmPassword, cPwd.count > 0 else {
            alertAlert?(.FailConfirmPasswordEmpty)
            return
        }
        
        if userRegister.count < 8 || userRegister.count > 16{
            alertAlert?(.FailUsernameCharecters)
            return
        }

        if pwd.count < 12 || pwd.count > 20 {
            alertAlert?(.FailPasswordCharecters)
            return
        }
        
        if !checkStrongPassword(password: pwd){
            alertAlert?(.FailPasswordnotStrong)
            return
        }
        
        if pwd != cPwd{
            alertAlert?(.FailPasswordnotMatch)
            return
        }
        
        
        haveAccountInList(username: userRegister, password: pwd) { status, withError in
            if status {
                alertAlert?(withError)
            } else {
                alertAlert?(withError)
            }
            return
        }
    }
    
    private func checkStrongPassword(password:String)->Bool{
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_+=-[]{};:'\",.<>/?\\|`~")
        let digitCharacterSet = CharacterSet.decimalDigits
        let passwordHasSpecialCharacter = password.rangeOfCharacter(from: specialCharacterSet) != nil
        let passwordHasDigit = password.rangeOfCharacter(from: digitCharacterSet) != nil
        return passwordHasSpecialCharacter && passwordHasDigit
    }
    
    private func haveAccountInList(username:String, password:String, completionCheck:((_ status:Bool, _ withError:StatusRegister)->Void))->Void {
        
        guard let dataAccount = UserDefaults.standard.data(forKey: Register.AccountList) else {
            saveNewAccount(newusername: username, password: password, oldListAccount: nil) { status, withError in
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
            saveNewAccount(newusername: username, password: password, oldListAccount: listAccount) { status, withError in
                completionCheck(status, withError)
            }
        }
    }
    
    private func saveNewAccount(newusername:String, password:String, oldListAccount:[AllAccountModel]?, completionSave:((_ status:Bool, _ withError:StatusRegister)->Void))->Void {
        
        let newUserAccount = AllAccountModel(username: newusername, password: password)
        
        if var haveOldListAccount = oldListAccount, haveOldListAccount.count > 0 {
            haveOldListAccount.append(newUserAccount)
            guard let encoder = try? JSONEncoder().encode(haveOldListAccount) else {
                completionSave(false, .FailJSONEncoder)
                return
            }
            UserDefaults.standard.setValue(encoder, forKey: Register.AccountList)
            completionSave(true, .Success)
        } else {
            guard let encoder = try? JSONEncoder().encode([newUserAccount]) else {
                completionSave(false, .FailJSONEncoder)
                return
            }
            UserDefaults.standard.setValue(encoder, forKey: Register.AccountList)
            completionSave(true, .Success)
        }
    }
}
