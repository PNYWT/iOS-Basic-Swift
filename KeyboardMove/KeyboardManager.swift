//
//  KeyboardManager.swift

//MARK: Log Edit
/*
 -> 25/04/24 Edit For Class EditProfileVM
 */

import Foundation
import UIKit

extension UIResponder {

    private struct Static {
        static weak var responder: UIResponder?
    }
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }
}

//MARK: Class KeyBoardManager
class KeyBoardManager {
    
    private var viewcontroller: UIViewController!
    private var subViewOriginalY: CGFloat!
    private var spaceStackIfNeed: CGFloat = 0.0
    
    init(viewController: UIViewController, spaceStack: CGFloat? = nil ) {
        self.viewcontroller = viewController
        self.subViewOriginalY = viewController.view.frame.origin.y
        
        if let space = spaceStack {
            self.spaceStackIfNeed = space
        }
    }
    
    public func setupNotificationCenterKeyBoard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func removeNotificationCenterKeyBoard(){
        NotificationCenter.default.removeObserver(self)
//        print("KeyBoardManager removeObserver success")
    }
    
    public func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        tap.cancelsTouchesInView = false
        viewcontroller?.view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        viewcontroller?.view?.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow Working")
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let currentTextField = UIResponder.currentFirst() as? UITextField, let viewMove = viewcontroller?.view else {
            return
        }
        let keyboardTopY = keyboardFrame.origin.y
//        print("currentTextField -> \(currentTextField.frame)")
//        print("currentTextField.superview -> \(currentTextField.superview)")
        let convertedTextFieldFrame = viewMove.convert(currentTextField.frame, to: currentTextField.superview)
//        print("convertedTextFieldFrame \(convertedTextFieldFrame)")
//        print("view \(viewMove.frame)")
        if convertedTextFieldFrame.origin.y == 0 {
            return
        }
        let textFieldBottomY = viewMove.frame.origin.y + abs(convertedTextFieldFrame.origin.y) + convertedTextFieldFrame.size.height + spaceStackIfNeed
        
//        print("textFieldBottomY -> \(textFieldBottomY)")
//        print("keyboardTopY -> \(keyboardTopY)")
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = abs(convertedTextFieldFrame.origin.y)
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            viewMove.frame.origin.y = newFrameY
        }
        return
    }
        
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let view = viewcontroller?.view {
            view.frame.origin.y = 0
        }
    }
}

