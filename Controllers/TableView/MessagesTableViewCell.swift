//
//  MessagesTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 13/09/2023.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var messageIMageView: UIImageView!
    @IBOutlet weak var messageNameLabel: UILabel!
    @IBOutlet weak var messageChatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
