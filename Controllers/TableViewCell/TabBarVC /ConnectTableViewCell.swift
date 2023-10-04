//
//  ConnectTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 08/09/2023.
//

import UIKit

protocol ConnectTableViewCellDelegate: AnyObject {
    func chatImageViewTapped(in cell: ConnectTableViewCell)
}

class ConnectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var connectImageView: UIImageView!
    @IBOutlet weak var connectCellLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    weak var delegate: ConnectTableViewCellDelegate?
    var tapGestureRecognizer: UITapGestureRecognizer?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chatImageViewTapped))
        chatImageView.isUserInteractionEnabled = true
            chatImageView.addGestureRecognizer(tapGesture)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func chatImageViewTapped() {
        delegate?.chatImageViewTapped(in: self)
     }

}
