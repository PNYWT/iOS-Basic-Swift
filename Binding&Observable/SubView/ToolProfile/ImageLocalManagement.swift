//
//  ImageLocalManagement.swift
//  PlayPlayPlus
//
//  Created by Dev on 10/4/2567 BE.
//

import Foundation
import UIKit

class ImageLocalManagement {
    
    private var localImagePath: URL? {
        get {
            return ConfigAccount.shared.user_logo_LocalPath
        }
    }
    
    public func saveImageAndGetPath(image: UIImage, completion:((_ imageLocalPath: URL) -> Void)? = nil) -> Void {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData() else {
            return // Handle the error of image conversion failure
        }

        let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
        try? data.write(to: filename)

        ConfigAccount.setupLocalProfileImage(needSave: true, localPath: filename)
        completion?(filename)
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public func deleteLocalImageCopyNow() {
        self.deleteImage(at: getDocumentsDirectory().appendingPathComponent("copy.png"))
        
    }
    
    private func deleteImage(at path: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path.path) {
            do {
                try fileManager.removeItem(at: path)
                print("File deleted successfully")
            } catch {
                print("Error deleting file:", error)
            }
        }
    }
    //MARK: isReviewProfile สำเร็จค่อยสั่งลบ
    /*
     if let imagePath = self?.getDocumentsDirectory().appendingPathComponent("copy.png") {
         self?.deleteImage(at: imagePath)
     }
     */
}
