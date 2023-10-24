//
//  AcceptedTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 19/10/2023.
//

import UIKit

class AcceptedTableViewCell: UITableViewCell {

    
    @IBOutlet weak var acceptedImage: UIImageView!
    
    @IBOutlet weak var acceptedUserName: UILabel!
    
    @IBOutlet weak var acceptedDate: UILabel!
    
    @IBOutlet weak var acceptedMessage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func messageButton(_ sender: UIButton) {
    }
    @IBAction func cancelButton(_ sender: UIButton) {
    }
    
}
