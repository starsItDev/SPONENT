//
//  ProfileFollowerCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 12/10/2023.
//

import UIKit

class ProfileFollowerCell: UITableViewCell {

    @IBOutlet weak var followerImageView: UIImageView!
    @IBOutlet weak var followerNameLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
