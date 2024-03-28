//
//  ConfigScreen.swift
//  Basic RxSwift
//
//  Created by Dev on 28/3/2567 BE.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ConfigApp{
    static func initWindows(isGoMain:Bool) {
        if isGoMain {
            DispatchQueue.main.async {
                let viewController:MainNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNav") as! MainNav
                UIApplication.currentWindow()?.rootViewController = viewController
                UIApplication.currentWindow()?.makeKeyAndVisible()
            }
        }else{
            DispatchQueue.main.async {
                let viewController:RegisterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                UIApplication.currentWindow()?.rootViewController = viewController
                UIApplication.currentWindow()?.makeKeyAndVisible()
            }
        }
    }
}


extension UIApplication {

    static func currentWindow() -> UIWindow? {
        return shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first
    }
    
    //เรียก RootVC จะเป็น Tabbar, Nav ก็ได้ ในกรณีที่ไม่มี Tabbar เป็น Root
    static func currentRootViewController() -> UIViewController? {
        return currentWindow()?.rootViewController
    }
    
    //เรียก TabbarVC
    static func currentTabBarController() -> UITabBarController? {
        return currentRootViewController() as? UITabBarController
    }
    
    //เรียก Nav
    static func currentNavigationController() -> UINavigationController? {
        var currentViewController = currentRootViewController()
        
        if let tabBarController = currentViewController as? UITabBarController,
           let selectedVC = tabBarController.selectedViewController {
            currentViewController = selectedVC
        }
        
        return currentViewController as? UINavigationController
    }
    
    //เรียกตาม VC บนสุด
    static func currentVisibleViewController() -> UIViewController? {
        var currentViewController = currentRootViewController()
        
        if let tabBarController = currentViewController as? UITabBarController,
           let selectedVC = tabBarController.selectedViewController {
            currentViewController = selectedVC
        }
        
        if let navigationController = currentViewController as? UINavigationController {
            currentViewController = navigationController.visibleViewController
        }
        
        while let presentedVC = currentViewController?.presentedViewController {
            currentViewController = presentedVC
        }
        
        return currentViewController
    }
}

extension UIViewController {
    func showAlert(title: String? = nil, message: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                observer.onNext(())
                observer.onCompleted()
            }))
            
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
