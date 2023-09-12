//
//  CornerRadius.swift
//  SPONENT
//
//  Created by Rao Ahmad on 10/08/2023.
//

import Foundation
import UIKit

extension UIView {
    
  @IBInspectable  var cornerRadius: CGFloat {
        get {
            return self.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
