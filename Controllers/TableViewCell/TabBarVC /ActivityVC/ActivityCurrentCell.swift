//
//  ActivityCurrentCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/10/2023.
//

import UIKit

class ActivityCurrentCell: UITableViewCell {
    
    @IBOutlet weak var currentTableImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var catAvatarImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var currentTableLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
