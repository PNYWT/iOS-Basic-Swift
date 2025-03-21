//
//  GlobalNewsExtension.swift
//  GlobalNewsView
//
//  Created by Dev on 10/1/2568 BE.
//

import UIKit

extension UIView {
    
    public func makeCornerRadius(radius: CGFloat, needMasksToBounds: Bool) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = needMasksToBounds
    }
    
    public func getViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    @MainActor
    public func pushNavigationToReadNews(modelNews: GlobaleListNews, needTransitionFlip: Bool = false, needAnimation: Bool = true) {
        let goWhere = GlobalNewsReadVC(title: modelNews.title, urlWebString: modelNews.webview)
        guard let currentVC = getOwningViewController()?.navigationController else {
            return
        }
        if needTransitionFlip {
            UIView.transition(with: currentVC.view, duration: 0.5, options: .transitionFlipFromRight) {
                currentVC.pushViewController(goWhere, animated: false)
            }
        } else {
            currentVC.pushViewController(goWhere, animated: needAnimation)
        }
    }
}

extension UIResponder {
    func getOwningViewController() -> UIViewController? {
        if let viewController = self as? UIViewController {
            return viewController
        } else {
            return next?.getOwningViewController()
        }
    }
}

extension String {
    static func formatNumberWithCommas(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

extension NSObject {
    public func printDataJSON(data: Data, showType: Bool = false) {
        if showType {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("printDataJSON -> ", jsonObject)
            } else {
                print("printDataJSON -> ", String(data: data, encoding: .utf8) ?? "")
            }
        } else {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("printDataJSON fail JSONSerialization.jsonObject -> ", String(data: data, encoding: .utf8) ?? "")
                return
            }
            if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                    print("printDataJSON -> \(prettyPrintedString)")
                } else {
                    print("printDataJSON fail JSONSerialization.data -> ", String(data: data, encoding: .utf8) ?? "")
                }
            } else {
                print("printDataJSON fail JSONSerialization.data -> ", String(data: data, encoding: .utf8) ?? "")
            }
        }
    }
    
}

