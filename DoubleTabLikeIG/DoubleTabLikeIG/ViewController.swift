//
//  ViewController.swift
//  DoubleTabLikeIG
//
//  Created by Train2 on 27/7/2565 BE.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.load(urlString: "https://www.planetware.com/wpimages/2020/02/france-in-pictures-beautiful-places-to-photograph-eiffel-tower.jpg")
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.numberOfTapsRequired = 2
        
        imgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTap(gesture : UITapGestureRecognizer){
        guard let gestureView = gesture.view else{
            return
        }
        
        let size = gestureView.frame.size.width/4
        let heart = UIImageView(image: UIImage(systemName: "heart.fill"))
        let locationTap:CGPoint = gesture.location(in: gesture.view)
        heart.frame = CGRect(x: locationTap.x-50, y: locationTap.y-100, width: size, height: size)
        heart.tintColor = .red
        gestureView.addSubview(heart)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            UIView.animate(withDuration: 1) {
                heart.alpha = 0
            } completion: { done in
                if done{
                    heart.removeFromSuperview()
                }
            }
        }
    }
}

extension UIImageView {
    func load(urlString : String) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

