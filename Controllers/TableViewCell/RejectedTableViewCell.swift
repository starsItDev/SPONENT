//
//  RejectedTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 20/10/2023.
//

import UIKit

protocol RejectedTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(inCell cell: RejectedTableViewCell)
}

class RejectedTableViewCell: UITableViewCell {
    weak var delegate: RejectedTableViewCellDelegate?
    @IBOutlet weak var rejectedImage: UIImageView!
    @IBOutlet weak var rejectedName: UILabel!
    @IBOutlet weak var rejectedDate: UILabel!
    @IBOutlet weak var rejectedMessage: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        delegate?.deleteButtonTapped(inCell: self)
    }
    
}
