//
//  CustomButton.swift
//  GlobalNewsView
//
//  Created by Dev on 10/1/2568 BE.
//

import UIKit

class CustomButton: UIButton {
    
    var colorSelect: UIColor! = .clear
    var colorNormal: UIColor! = .clear
    
    init(colorSelect: UIColor!, 
         colorNormal: UIColor!,
         titleColorNormal: UIColor!,
         titleColorSelect: UIColor? = nil,
         isHighlighted: Bool,
         isSelected: Bool) {
        self.colorSelect = colorSelect
        self.colorNormal = colorNormal
        super.init(frame: .zero)
        self.isHighlighted = isHighlighted
        self.isSelected = isSelected
        self.setTitleColor(titleColorNormal, for: .normal)
        if let haveTitleSelect = titleColorSelect {
            self.setTitleColor(haveTitleSelect, for: .selected)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted == true ? 0.5:1.0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected == true ? colorSelect : colorNormal
        }
    }
}
