//
//  HelloTableViewCell.swift
//  TestCreateSDK
//
//  Created by CallmeOni on 20/3/2567 BE.
//

import UIKit

class HelloTableViewCell: UITableViewCell {
    
    static let identifier = "HelloTableViewCell"

    @IBOutlet weak var lbIndexPath: UILabel!
    @IBOutlet weak var lbHelloIndexPath: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbHelloIndexPath.font = UIFont(name: "Prompt-Bold", size: 30)
        lbIndexPath.font = UIFont(name: "Prompt-Regular", size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configContentCell(hello:String, indexPath:IndexPath){
        lbHelloIndexPath.text = hello
        lbIndexPath.text = String(format: "row : %d", indexPath.item)
    }
}
