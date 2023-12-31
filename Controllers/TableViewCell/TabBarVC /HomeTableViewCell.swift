//
//  HomeTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/08/2023.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    //MARK: - Variable
    @IBOutlet weak var homeTableImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var catAvatarImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var homeTableLocation: UILabel!
    var locationName: String?
    
    //MARK: - Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
