//
//  KingFisher Image.swift
//  SPONENT
//
//  Created by Rao Ahmad on 04/10/2023.
//

import Foundation
import UIKit
import Kingfisher

extension UIViewController {
    func loadImage(from urlString: String, into imageView: UIImageView, placeholder: UIImage? = nil) {
        if let url = URL(string: urlString.replacingOccurrences(of: "http://", with: "https://")) {
            DispatchQueue.main.async {
                imageView.kf.setImage(with: url, placeholder: placeholder)
            }
        }
    }
}
