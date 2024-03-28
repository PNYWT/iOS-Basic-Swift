//
//  AccountModel.swift
//  Basic RxSwift
//
//  Created by Dev on 28/3/2567 BE.
//

import Foundation

struct AllAccountModel:Codable{
    let username:String!
    let password:String!
    let email:String!
}

enum StatusRegister:String, Error {
    case FailJSONDecoder = "JSONDecoder error."
    case FailJSONEncoder = "JSONEncoder error."
    case FailAlreadyhaveAccount = "You already have account."
    case Success = "Create Account Success."
}
