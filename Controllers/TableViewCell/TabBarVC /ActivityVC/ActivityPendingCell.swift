//
//  ActivityTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

class ActivityPendingCell: UITableViewCell {

    @IBOutlet weak var pendingTableImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var catAvatarImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pendingTableLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
