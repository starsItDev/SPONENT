//
//  GradientColour.swift
//  SPONENT
//
//  Created by Rao Ahmad on 10/08/2023.
//

import Foundation
import UIKit



class GradientView: UIView {

    @IBInspectable var startColor: UIColor = .white {
        didSet {
            updateGradient()
    }
}
    @IBInspectable var endColor: UIColor = .black {
        didSet {
            updateGradient()
    }
}
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
}
    
    private func updateGradient() {
        guard let layer = self.layer as? CAGradientLayer else { return }
        layer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
