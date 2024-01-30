//
//  ImageCellTV.swift
//  SPONENT
//
//  Created by StarsDev on 30/01/2024.
//

import UIKit

class ImageCellTV: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imageBtnTap: UIButton!
    
    @IBOutlet weak var viewUIView: UIView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
