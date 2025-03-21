//
//  Login.swift
//  Basic RxSwift and Alamofire
//
//  Created by Dev on 28/3/2567 BE.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    let username = PublishSubject<String>()
    let password = PublishSubject<String>()
    
    func isValid() -> Observable<Bool> {
        return Observable.combineLatest(username.asObservable(), password.asObservable()).map { username, password in
            return username.count > 4 && password.count > 8
        }
    }
}
