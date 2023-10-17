//
//  ActivityPastCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/10/2023.
//

import UIKit

class ActivityPastCell: UITableViewCell {

    @IBOutlet weak var pastTableImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var catAvatarImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pastTableLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
