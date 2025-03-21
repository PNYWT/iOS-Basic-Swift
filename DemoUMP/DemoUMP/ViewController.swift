//
//  ViewController.swift
//  DemoUMP
//
//  Created by Dev on 22/1/2568 BE.
//

import UIKit
import UserMessagingPlatform

class ViewController: UIViewController {
    
    private lazy var admobViewModel: AdmobViewModel = {
        return AdmobViewModel(vc: self)
    }()
    @IBOutlet weak var btnModify: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        admobViewModel.callPermission(completion: {
            self.btnModify.isEnabled = UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
        })
    }
    
    @IBAction func actionModify(_ sender: Any) {
        UMPConsentForm.presentPrivacyOptionsForm(from: self) { _ in
            self.admobViewModel.callAdmobBanner()
        }
    }
}

