//
//  HelloTableViewCell.swift
//  TestCreateSDK
//
//  Created by CallmeOni on 20/3/2567 BE.
//

import UIKit

class HelloTableViewCell: UITableViewCell {
    
    static let identifier = "HelloTableViewCell"

    @IBOutlet weak var lbHelloIndexPath: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
