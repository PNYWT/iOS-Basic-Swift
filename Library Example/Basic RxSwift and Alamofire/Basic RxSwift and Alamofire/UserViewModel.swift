//
//  UserViewModel.swift
//  Basic RxSwift and Alamofire
//
//  Created by Dev on 28/3/2567 BE.
//

import Foundation
import RxSwift
import RxCocoa

class UserViewModel {
    
    private let userService: UserService
    let usersData = PublishSubject<[UserModel]>()
    private var disposeBag = DisposeBag()
    
    init(userService: UserService = UserService()) {
        self.userService = userService
    }
    
    public func fetchUserData() {
        userService.fetchUser().subscribe(onNext: { user in
            self.usersData.onNext(user)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("Fetch Data Done")
        }).disposed(by: disposeBag)
    }
}
