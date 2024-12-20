//
//  EncryptAndDecrypt.swift
//  TestView
//
//  Created by Dev on 4/4/2567 BE.
//

import Foundation
import CryptoKit

class EncryptAndDecrypt {
    
    /*
     guard let tokenEncryptedString = ConfigAppInfo.encryptAES128(encryptWith: realToken, key: "J9TX6HkS9opGx5se", iv: nil, useIV: false) else {
         return
     }
     
     guard let tokenDecrypt = ConfigAppInfo.decryptAES128(decryptWith: tokenEncryptedString, key: "J9TX6HkS9opGx5se", iv: nil, useIV: false) else {
         return
     }
     */
    
    func encryptAES128(encryptWith: String, key: String, iv: String?, useIV: Bool) -> String? {
        do {
            guard let data = encryptWith.data(using: .utf8) else {
                return nil
            }
            
            let encrypted: [UInt8]
            
            if useIV {
                guard let haveIV = iv else {
                    return nil
                }
                
                let aes = try AES(key: key.bytes, blockMode: CBC(iv: haveIV.bytes), padding: .pkcs7)
                encrypted = try aes.encrypt(data.bytes)
            } else {
                let aes = try AES(key: key.bytes, blockMode: ECB(), padding: .pkcs7)
                encrypted = try aes.encrypt(data.bytes)
            }
            
            let encryptedData = Data(encrypted)
            return encryptedData.base64EncodedString()
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func decryptAES128(decryptWith: String, key: String, iv: String?, useIV: Bool) -> String? {
        do {
            guard let data = Data(base64Encoded: decryptWith) else {
                return nil
            }
            
            let decrypted: [UInt8]
            
            if useIV {
                guard let haveIV = iv else {
                    return nil
                }
                
                let aes = try AES(key: key.bytes, blockMode: CBC(iv: haveIV.bytes), padding: .pkcs7)
                decrypted = try aes.decrypt(data.bytes)
            } else {
                let aes = try AES(key: key.bytes, blockMode: ECB(), padding: .pkcs7)
                decrypted = try aes.decrypt(data.bytes)
            }
            
            return String(data: Data(decrypted), encoding: .utf8)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}
