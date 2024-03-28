//
//  Service.swift
//  Basic RxSwift and Alamofire
//
//  Created by Dev on 28/3/2567 BE.
//

import Foundation
import Alamofire
import RxSwift

class UserService {
    func fetchUser() -> Observable<[UserModel]> { //CallBack Observable กลับ
        // Create Observable
        return Observable.create { observer in
            let url = "https://yourapi.com/user"
            AF.request(url).responseDecodable(of: [UserModel].self) { response in
                switch response.result {
                case .success(let user):
                    observer.onNext(user) // onNext โยนค่ากลับ
                    observer.onCompleted() // onCompleted แจ้งว่าเสร็จแล้ว จะทำอะไรต่อ
                case .failure(let error):
                    observer.onError(error)
                    observer.onCompleted() // onCompleted แจ้งว่าเสร็จแล้ว จะทำอะไรต่อ
                }
            }
            return Disposables.create {
                AF.cancelAllRequests()
            }
        }
    }
}
