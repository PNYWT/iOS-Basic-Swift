//
//  SKTableViewCell.swift
//  SkeletonViewDemo
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import SDWebImage
import SkeletonView

class SKTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "cellSk"

    @IBOutlet weak var dogImageView: UIImageView!
    
    @IBOutlet weak var lbDogURL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dogImageView.image = nil
        lbDogURL.text = nil
    }

    public func setupCell(url: String?) {
        self.showAnimatedGradientSkeleton()
        dogImageView.contentMode = .scaleToFill
        dogImageView.sd_setImage(with: URL(string: url ?? "")) { [weak self] image, _, _, _ in
            if let _ = image {
                self?.stopSkeletonAnimation()
                self?.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                self?.dogImageView.layer.cornerRadius = 8.0
                self?.dogImageView.layer.masksToBounds = true
                self?.lbDogURL.text = url
            }
        }
    }
}
