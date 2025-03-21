//
//  HeroController.swift
//  HeroAnimation
//
//  Created by Dev on 7/2/2568 BE.
//

import UIKit
import Hero

extension UIViewController {
    
    func presentHeroWith(controller: UIViewController, presenting: HeroDefaultAnimationType? = nil, dismissing: HeroDefaultAnimationType? = nil) {
        /*
         
         // this configures the built in animation
         //    vc2.hero.modalAnimationType = .zoom
         //    vc2.hero.modalAnimationType = .pageIn(direction: .left)
         //    vc2.hero.modalAnimationType = .pull(direction: .left)
         //    vc2.hero.modalAnimationType = .autoReverse(presenting: .pageIn(direction: .left))
         vc.hero.modalAnimationType = .selectBy(presenting: .pull(direction: .left), dismissing: .slide(direction: .down))
         */
        controller.modalPresentationStyle = .fullScreen
        controller.hero.isEnabled = true
        if let havePresentType = presenting {
            if let haveDismissType = dismissing {
                controller.hero.modalAnimationType = .selectBy(presenting: havePresentType, dismissing: haveDismissType)
            } else {
                controller.hero.modalAnimationType = .selectBy(presenting: havePresentType, dismissing: havePresentType)
            }
        }
        present(controller, animated: true, completion: nil)
    }
}
