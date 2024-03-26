//
//  ViewController.swift
//  TestUseSDK
//
//  Created by CallmeOni on 20/3/2567 BE.
//

import UIKit
import TestCreateSDK

class ViewController: UIViewController {

    var manager = Manager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openVCASDK(_ sender: Any) {
        let vc = manager.viewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

