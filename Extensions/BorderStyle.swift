//
//  BorderStyle.swift
//  SPONENT
//
//  Created by Rao Ahmad on 23/08/2023.
//

import Foundation
import UIKit

extension UIView {
    
    func applyBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
    }
}
