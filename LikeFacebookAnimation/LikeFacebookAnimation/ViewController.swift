//
//  ViewController.swift
//  LikeFacebookAnimation
//
//  Created by Train2 on 27/7/2565 BE.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        let curvedView = CurvedView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        curvedView.backgroundColor = .red
        self.view.addSubview(curvedView)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTap)))
    }
    
    @objc func tapTap(){
        (0...10).forEach { _ in
            generateAnimatedViews()
        }
    }
    
    fileprivate func generateAnimatedViews(){
        let image = drand48() > 0.5 ? UIImage(named: "like") : UIImage(named: "love")
        let imageLike = UIImageView(image: image)
        let dimension = 20 + drand48() * 10
        imageLike.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = customPath().cgPath
        animation.duration = 2 + drand48() * 3
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        imageLike.layer.add(animation, forKey:  nil)
        
        self.view.addSubview(imageLike)
    }
}


func customPath() -> UIBezierPath{
    let window = UIWindow()
    print("window.frame.maxX \(window.frame.midX)")
    let path = UIBezierPath()
    path.move(to: CGPoint(x: window.frame.midX, y: window.frame.midY))
    let endPoint = CGPoint(x: window.frame.maxX + 100, y: window.frame.midY)
    let randomYShift = 200 + drand48() * 300
    let cp1 = CGPoint(x: 0, y: 100 - randomYShift)
    let cp2 = CGPoint(x: 0, y: 300 + randomYShift)
    
    path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
    return path
}

class CurvedView: UIView{
    override func draw(_ rect: CGRect) {
        let path = customPath()
        
        path.lineWidth = 3
        path.stroke()
    }
}

