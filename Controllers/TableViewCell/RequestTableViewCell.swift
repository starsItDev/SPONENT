//
//  RequestTableViewCell.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var requestView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        requestView.layer.borderWidth = 0.8
//        requestView.layer.borderColor = UIColor.lightGray.cgColor
//        requestView.layer.shadowColor = UIColor.black.cgColor
//        requestView.layer.shadowOpacity = 0.2
//        requestView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        requestView.layer.shadowRadius = 2
//        requestView.layer.shadowPath = UIBezierPath(rect: requestView.bounds).cgPath

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
