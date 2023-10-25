//
//  AcceptedTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 19/10/2023.
//

import UIKit

protocol AcceptedTableViewCellDelegate: AnyObject {
    func cancelButtonTapped(inCell cell: AcceptedTableViewCell)
}

class AcceptedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var acceptedImage: UIImageView!
    @IBOutlet weak var acceptedUserName: UILabel!
    @IBOutlet weak var acceptedDate: UILabel!
    @IBOutlet weak var acceptedMessage: UILabel!
    @IBOutlet weak var acceptedMessageBtn: UIButton!
    @IBOutlet weak var acceptedCancelBtn: UIButton!
    weak var delegate: AcceptedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func messageButton(_ sender: UIButton) {
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        delegate?.cancelButtonTapped(inCell: self)
    }
    
}
