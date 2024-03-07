//
//  RequestTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

protocol RequestTableViewCellDelegate: AnyObject {
    func acceptButtonTapped(inCell cell: RequestTableViewCell)
    func rejectButtonTapped(inCell cell: RequestTableViewCell)
    func chatButtonTapped(inCell cell: RequestTableViewCell)
}

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var pendingImage: UIImageView!
    @IBOutlet weak var pendingUserName: UILabel!
    @IBOutlet weak var pendingdate: UILabel!
    @IBOutlet weak var pendingMessage: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    weak var delegate: RequestTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptButton(_ sender: UIButton) {
        delegate?.acceptButtonTapped(inCell: self)
    }
 
    @IBAction func declineButton(_ sender: UIButton) {
        delegate?.rejectButtonTapped(inCell: self)
    }
    
    @IBAction func chatButton(_ sender: UIButton) {
        delegate?.chatButtonTapped(inCell: self)
    }
    
}
