//
//  EncryptAndDecrypt.swift
//  TestView
//
//  Created by Dev on 4/4/2567 BE.
//

import Foundation
import CryptoKit
import KeychainSwift

class EncryptAndDecrypt {
    
    static let username = "usernameKey"
    static let password = "passwordKey"
    private let symmetricKeyChain = "symmetricKey"
    
    private var symmetricKey:SymmetricKey!
    let keyChain = KeychainSwift()
    
    init() {
        symmetricKey = getSymmetricKey()
    }
    
    private func getSymmetricKey() -> SymmetricKey? {
        if let keyData = keyChain.getData(symmetricKeyChain) {
            return SymmetricKey(data: keyData) //ครั้งต่อๆ ไปใช้ค่าของครั้งแรกที่เก็บไว้
        }
        
        //ครั้งแรก สร้างรหัสขึ้นมา
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data(Array($0)) }
        keyChain.set(keyData, forKey: symmetricKeyChain)
        return newKey
    }
    
    func encryptObject(object: String) -> String? {
        let passwordData = Data(object.utf8)
        guard let encryptedData = try? AES.GCM.seal(passwordData, using: symmetricKey).combined else {
            return nil
        }
        return encryptedData.base64EncodedString()
    }

    func decryptObject(encryptedObject: String) -> String? {
        guard let data = Data(base64Encoded: encryptedObject),
            let sealedBox = try? AES.GCM.SealedBox(combined: data),
            let decryptedData = try? AES.GCM.open(sealedBox, using: symmetricKey) else {
                return nil
        }
        return String(data: decryptedData, encoding: .utf8)
    }
}
