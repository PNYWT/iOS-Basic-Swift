//
//  EncryptAndDecrypt CryptoSwift.swift
//  TestView
//
//  Created by Dev on 4/4/2567 BE.
//

/*
 AES-128: ให้ความปลอดภัยสูงและเพียงพอสำหรับการใช้งานทั่วไปในปัจจุบัน เป็นตัวเลือกที่ดีเมื่อพิจารณาความสมดุลระหว่างความปลอดภัยและประสิทธิภาพ.
 AES-192: ให้ความปลอดภัยสูงขึ้น แต่ใช้งานน้อยกว่า AES-128 และ AES-256.
 AES-256: ให้ระดับความปลอดภัยสูงสุด เหมาะสำหรับข้อมูลที่ต้องการความปลอดภัยสูงมาก แต่ใช้ทรัพยากรในการประมวลผลมากกว่า.
 AES-128 ใช้คีย์ขนาด 128 บิต ซึ่งเท่ากับ 16 ไบต์
 AES-192 ใช้คีย์ขนาด 192 บิต ซึ่งเท่ากับ 24 ไบต์
 AES-256 ใช้คีย์ขนาด 256 บิต ซึ่งเท่ากับ 32 ไบต์
 */

import Foundation
import KeychainSwift

enum KeychainType: String {
    case KeyAES128 = "KeyAES128" // ใช้เข้ารหัสถอดรหัสพวกที่จะเก็บไว้ใน app, ใช้ขนาด 16 byte เป็น key ASE128
    case TokenService = "TokenService"
}

class KeychainSwiftObject: NSObject {
    
    static func saveKeyASE128() {
        let keychain = KeychainSwift()
        let uuidString = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        keychain.set(uuidString, forKey: KeychainType.KeyAES128.rawValue)
        KeychainSwiftObject.saveKey(value: "Hello World", forKey: .TokenService)
    }
    
    // string
    static func saveKey(value: String, forKey: KeychainType) {
        let keychain = KeychainSwift()
        guard let keyASE = KeychainSwiftObject.getValue(forKey: .KeyAES128) else {
            return
        }
        guard let encryptObject = Cryptographic.encryptAES128(encryptWith: value, key: keyASE, iv: nil) else {
            return
        }
        keychain.set(encryptObject, forKey: forKey.rawValue)
    }
    
    // string
    static func getValue(forKey: KeychainType) -> String? {
        let keychain = KeychainSwift()
        guard let object = keychain.get(forKey.rawValue) else {
            print("Not Found Key")
            return nil
        }
        if forKey == .KeyAES128 {
            return object
        } else {
            guard let keyASE = KeychainSwiftObject.getValue(forKey: .KeyAES128) else {
                return nil
            }
            guard let decryptObject = Cryptographic.decryptAES128(decryptWith: object, key: keyASE, iv: nil) else {
                return nil
            }
            return decryptObject
        }
    }
    
    // data
    static func saveData(value: Data, forKey: KeychainType) {
        let keychain = KeychainSwift()
        keychain.set(value, forKey: forKey.rawValue)
    }
    
    // data
    static func getDataValue(forKey: KeychainType) -> Data? {
        let keychain = KeychainSwift()
        guard let object = keychain.getData(forKey.rawValue) else {
            print("Not Found Key")
            return nil
        }
        return object
    }
    
    static func removeAllList() {
        let keychain = KeychainSwift()
        keychain.clear()
    }
    
    static func getAllList() {
        let keychain = KeychainSwift()
    }
}

class Cryptographic {
    // key, vi 16 characters for AES-128
    static func encryptAES128(encryptWith: String, key: String, iv: String? = nil) -> String? {
        do {
            guard let data = encryptWith.data(using: .utf8) else {
                return nil
            }
            
            let encrypted: [UInt8]
            
            if let useIV = iv {
                let aes = try AES(key: Array(key.prefix(16).utf8), blockMode: CBC(iv: useIV.bytes), padding: .pkcs7)
                encrypted = try aes.encrypt(data.bytes)
            } else {
                let aes = try AES(key: Array(key.prefix(16).utf8), blockMode: ECB(), padding: .pkcs7)
                encrypted = try aes.encrypt(data.bytes)
            }
            
            let encryptedData = Data(encrypted)
            return encryptedData.base64EncodedString()
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    static func decryptAES128(decryptWith: String, key: String , iv: String? = nil) -> String? {
        do {
            guard let data = Data(base64Encoded: decryptWith) else {
                return nil
            }
            
            let decrypted: [UInt8]
            
            if let useIV = iv {
                let aes = try AES(key: Array(key.prefix(16).utf8), blockMode: CBC(iv: useIV.bytes), padding: .pkcs7)
                decrypted = try aes.decrypt(data.bytes)
            } else {
                let aes = try AES(key: Array(key.prefix(16).utf8), blockMode: ECB(), padding: .pkcs7)
                decrypted = try aes.decrypt(data.bytes)
            }
            
            return String(data: Data(decrypted), encoding: .utf8)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}
