//
//  ViewController.swift
//  HowToCryptoSwift
//
//  Created by Dev on 19/6/2567 BE.
//

import UIKit
import CryptoSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let originalString = "Hello, AES!"
        let keyString = "mysecretkey12345" // Key should be 16 bytes long for AES-128

        if let encryptedText = aesEncrypt(plainText: originalString, key: keyString) {
            print("Encrypted Text: \(encryptedText)")
            
            if let decryptedText = aesDecrypt(encryptedText: encryptedText, key: keyString) {
                print("Decrypted Text: \(decryptedText)")
            }
        }
    }

    private func aesEncrypt(plainText: String, key: String) -> String? {
        do {
            let keyBytes = Array(key.utf8)
            let ivBytes = AES.randomIV(AES.blockSize)
            
            let aes = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes), padding: .pkcs7)
            let encryptedBytes = try aes.encrypt(Array(plainText.utf8))
            
            let encryptedData = Data(ivBytes + encryptedBytes)
            return encryptedData.base64EncodedString()
        } catch {
            print("Error encrypting: \(error)")
            return nil
        }
    }

    private func aesDecrypt(encryptedText: String, key: String) -> String? {
        do {
            let encryptedData = Data(base64Encoded: encryptedText)!
            let ivBytes = Array(encryptedData.prefix(16))
            let encryptedBytes = Array(encryptedData.suffix(from: 16))
            
            let aes = try AES(key: Array(key.utf8), blockMode: CBC(iv: ivBytes), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(encryptedBytes)
            
            return String(bytes: decryptedBytes, encoding: .utf8)
        } catch {
            print("Error decrypting: \(error)")
            return nil
        }
    }
}

