//
//  ProfileFollowerCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 12/10/2023.
//

import UIKit

protocol ProfileFollowerTableViewCellDelegate: AnyObject {
    func chatImageViewTapped(in cell: ProfileFollowerCell)
}

class ProfileFollowerCell: UITableViewCell {

    @IBOutlet weak var followerImageView: UIImageView!
    @IBOutlet weak var followerNameLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    weak var delegate: ProfileFollowerTableViewCellDelegate?
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
