//
//  FontExtension.swift
//  TestCreateSDK
//
//  Created by Dev on 29/3/2567 BE.
//

import Foundation
import UIKit

public class FontManager {
    
    public static var shared = FontManager()
    
    public func setupSDKFont() {
        UIFont.jbs_registerFont(
            withFilenameString: "Prompt-Bold.ttf",
            bundle: Bundle(identifier: "callmeOni.TestCreateSDK")!
        )
        UIFont.jbs_registerFont(
            withFilenameString: "Prompt-Regular.ttf",
            bundle: Bundle(identifier: "callmeOni.TestCreateSDK")!
        )
    }
}

public extension UIFont {
    static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {

        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }

        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

}
