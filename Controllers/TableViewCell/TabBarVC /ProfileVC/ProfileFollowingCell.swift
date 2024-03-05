//
//  ProfileFollowingCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 12/10/2023.
//

import UIKit

protocol ProfileFollowingTableViewCellDelegate: AnyObject {
    func followingChatImageViewTapped(in cell: ProfileFollowingCell)
}
class ProfileFollowingCell: UITableViewCell {

    @IBOutlet weak var followingImageView: UIImageView!
    @IBOutlet weak var followingNameLabel: UILabel!
    @IBOutlet weak var followingChatImageView: UIImageView!
    weak var delegate: ProfileFollowingTableViewCellDelegate?
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chatImageViewTapped))
        followingChatImageView.isUserInteractionEnabled = true
        followingChatImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @objc func chatImageViewTapped() {
        delegate?.followingChatImageViewTapped(in: self)
     }
}
