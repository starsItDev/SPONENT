//
//  MessageCellUser.swift
//  SPONENT
//
//  Created by StarsDev on 03/10/2023.
//

import UIKit

class MessageCellUser: UITableViewCell {

    
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
