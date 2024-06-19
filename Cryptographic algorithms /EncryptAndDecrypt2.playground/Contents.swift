import UIKit
import CryptoKit

// สร้าง SymmetricKey จากพาสเวิร์ด
func generateKey(from password: String) -> SymmetricKey {
    let passwordData = password.data(using: .utf8)!
    let hash = SHA256.hash(data: passwordData) // 256 bits
    return SymmetricKey(data: hash)
}

// ใช้พาสเวิร์ดในการสร้าง SymmetricKey
let password = "QWERTYUIOP{!@#$%^&*()" // <- ควรเก็บใน Keychain, // AES requires 16-byte
let key = generateKey(from: password) // 256 bits 32-byte
print("key -> \(key)")

func encrypt(_ string: String) -> String? {
    guard let data = string.data(using: .utf8) else { return nil }
    let sealedBox = try? AES.GCM.seal(data, using: key)
    return sealedBox?.combined?.base64EncodedString()
}

func decrypt(_ base64String: String) -> String? {
    guard let data = Data(base64Encoded: base64String),
          let sealedBox = try? AES.GCM.SealedBox(combined: data),
          let decryptedData = try? AES.GCM.open(sealedBox, using: key),
          let decryptedString = String(data: decryptedData, encoding: .utf8) else {
        return nil
    }
    return decryptedString
}


let encryptedUsername = encrypt("hello")
let encryptedUserID = encrypt("093823")
print("encryptedUsername -> \(encryptedUsername)")
print("encryptedUserID -> \(encryptedUserID)")

if let haveName = encryptedUsername {
    let decryptedUsername = decrypt(haveName)
    print("decryptedUsername -> \(decryptedUsername)")
}

if let haveUserID = encryptedUserID {
    let decryptedUserID = decrypt(haveUserID)
    print("decryptedUserID -> \(decryptedUserID)")
}
