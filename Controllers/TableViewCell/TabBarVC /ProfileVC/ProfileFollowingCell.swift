//
//  ProfileFollowingCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 12/10/2023.
//

import UIKit

class ProfileFollowingCell: UITableViewCell {

    @IBOutlet weak var followingImageView: UIImageView!
    @IBOutlet weak var followingNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
