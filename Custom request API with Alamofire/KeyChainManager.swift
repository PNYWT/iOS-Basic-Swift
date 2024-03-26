//
//  KeyChainManager.swift

import Foundation
import Security
import UIKit

class KeyChainManager {
    
    static let saveForAPIKEY = "APIKEY"
    /*
     KeyChainManager.storeKey("Your API KEY", forKey: KeyChainManager.saveForAPIKEY) <- Set in Appdelegate didFinishLaunchingWithOptions
     */

    static func storeKey(_ key: String, forKey keyName: String) {
        let data = Data(key.utf8)
        
        let queryCheck = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyName
        ] as [String: Any]
        
        let statusCheck = SecItemCopyMatching(queryCheck as CFDictionary, nil)
        
        if statusCheck == errSecSuccess {
            let attributesToUpdate = [kSecValueData as String: data]
            SecItemUpdate(queryCheck as CFDictionary, attributesToUpdate as CFDictionary)
        } else {
            let queryAdd = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: keyName,
                kSecValueData as String: data
            ] as [String: Any]
            
            SecItemAdd(queryAdd as CFDictionary, nil)
        }
    }
    
    
    static func retrieveKey(forKey keyName: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyName,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data,
               let key = String(data: retrievedData, encoding: .utf8) {
                return key
            }
        }
        return nil
    }
    
    static var newIMEI: String {
        let keyName = "deviceInstall"
        if let retrievedString_new = KeyChainManager.retrieveKey(forKey: keyName) {
            return retrievedString_new
        } else {
            var strSave: String = ""
            if let vendor = UIDevice.current.identifierForVendor?.uuidString {
                strSave = vendor
            } else {
                strSave = UUID().uuidString
            }
            strSave = strSave.replacingOccurrences(of: "-", with: "")
            KeyChainManager.storeKey(strSave, forKey: keyName)
            return strSave
        }
    }
    
    static func removeKey(forKey keyName: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyName
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("Key successfully removed.")
        }else if status == errSecItemNotFound {
            print("Key not found in Keychain.")
        }
    }
}

