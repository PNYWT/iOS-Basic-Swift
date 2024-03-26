//
//  AllAccountModel.swift
//  ProjectSoftwareTest
//
//  Created by CallmeOni on 24/3/2567 BE.
//

import Foundation

struct AllAccountModel:Codable{
    let username:String!
    let password:String!
}

enum StatusRegister:String {
    case FailUsernameEmpty = "Username is Empty."
    case FailPasswordEmpty = "Password is Empty."
    case FailConfirmPasswordEmpty = "Comfirm password is Empty."
    case FailUsernameCharecters = "Please Input username 8-16 characters."
    case FailPasswordCharecters = "Please Input password 12-20 characters."
    case FailPasswordnotStrong = "Password is not strong."
    case FailPasswordnotMatch = "Password is not match."
    case FailJSONDecoder = "JSONDecoder error."
    case FailJSONEncoder = "JSONEncoder error."
    case FailAlreadyhaveAccount = "You already have account."
    case Success = "Create Account Success."
}
