//
//  File.swift
//  SPONENT
//
//  Created by Rao Ahmad on 23/08/2023.
//

import Foundation
import UIKit

extension UIViewController {
    
    func setupTapGesture<T: UIView>(for view: T, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
        
    }
}
