//
//  Manager.swift
//  TestCreateSDK
//
//  Created by CallmeOni on 19/3/2567 BE.
//

import Foundation
import UIKit

public class Manager{
    public init(){
        
    }
    
    public func viewController() -> UIViewController{
        let bundle = Bundle(for: ViewControllerA.self)
        let vc = ViewControllerA(nibName: "ViewControllerA", bundle: bundle)
        return vc
    }
}
