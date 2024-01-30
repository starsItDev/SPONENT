//
//  TextFeild.swift
//  Socket
//
//  Created by StarsDev on 26/12/2023.
//

import UIKit

class TypingBubbleView: UIView {
    private let bubbleView: BubbleView
    private let textLayer: CATextLayer
    private var dotLayers: [CALayer] = []
    
    override init(frame: CGRect) {
        bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        textLayer = CATextLayer()
        
        super.init(frame: frame)
        
        setupBubbleView()
        setupTextLayer()
        setupDotLayers()
        startTypingAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBubbleView() {
        addSubview(bubbleView)
    }
    func startAnimating() {
            for (_, dotLayer) in dotLayers.enumerated() {
                dotLayer.isHidden = false
            }
        }

        // Stop the typing animation
        func stopAnimating() {
            for (_, dotLayer) in dotLayers.enumerated() {
                dotLayer.isHidden = true
            }
        }
    private func setupTextLayer() {
        textLayer.frame = bubbleView.bounds.insetBy(dx: 10, dy: 10)
        textLayer.string = ""
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        bubbleView.layer.addSublayer(textLayer)
    }
    private func setupDotLayers() {
        let dotSize: CGFloat = 12
        let spaceBetweenDots: CGFloat = 10

        for i in 0..<3 {
            let dotLayer = CALayer()
            dotLayer.bounds = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
            dotLayer.cornerRadius = dotSize / 2
            dotLayer.backgroundColor = UIColor.darkGray.cgColor
            let xPosition = bubbleView.bounds.width - CGFloat(12 + i * Int((dotSize + spaceBetweenDots)))
            dotLayer.position = CGPoint(x: xPosition, y: bubbleView.bounds.height - dotSize / 1)
            bubbleView.layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
    }

//    private func setupDotLayers() {
//        for i in 0..<4 {
//            let dotLayer = CALayer()
//            dotLayer.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
//            dotLayer.cornerRadius = 7.5
//            dotLayer.backgroundColor = UIColor.darkGray.cgColor
//            dotLayer.position = CGPoint(x: bubbleView.bounds.width - CGFloat(15 + i * 15), y: bubbleView.bounds.height - 15)
//            bubbleView.layer.addSublayer(dotLayer)
//            dotLayers.append(dotLayer)
//        }
//    }
    
    private func startTypingAnimation() {
        for (index, dotLayer) in dotLayers.enumerated() {
            let dotAnimation = CAKeyframeAnimation(keyPath: "opacity")
            dotAnimation.values = [0.0, 0.5, 1.0, 0.5, 0.0]
            dotAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            dotAnimation.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 4)
            dotAnimation.repeatCount = .infinity
            dotAnimation.beginTime = CACurrentMediaTime() + Double(index) * 0.2 // stagger the animations
            dotLayer.add(dotAnimation, forKey: "dotOpacityAnimation")
        }
    }
}

class BubbleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bubblePath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        
        UIColor.clear.setFill()
        bubblePath.fill()
    }
}

extension UIViewController {
    func addTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap() {
        view.endEditing(true) // Dismiss keyboard
    }
}

extension UITextField: UITextFieldDelegate {
    public func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))

        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        self.inputAccessoryView = toolbar
        self.delegate = self  // Set the delegate to self to handle return key
    }

    @objc private func doneButtonTapped() {
        self.resignFirstResponder()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIView{
    
    func roundRadiusCorner(cornerRadius: CGFloat){
//        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
 
}

extension UIView{
    func setupShadowTopView(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.masksToBounds = false
    }
    func setupShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.masksToBounds = false
    }
    func setupCellShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.masksToBounds = false
    }
}

extension String {
    // Extracts the time string from HTML content
    func extractTimeFromHTML() -> String? {
        guard let startIndex = self.range(of: "title=\"")?.upperBound,
              let endIndex = self.range(of: "\">", range: startIndex..<self.endIndex)?.lowerBound else {
            return nil
        }
        let timeString = String(self[startIndex..<endIndex])
        return timeString
    }
}

//
//  CornerRadius.swift
//  SPONENT
//
//  Created by Rao Ahmad on 10/08/2023.
//

//import Foundation
//import UIKit
//
//extension UIView {
//
//  @IBInspectable  var cornerRadius: CGFloat {
//        get {
//            return self.cornerRadius
//        }
//        set {
//            self.layer.cornerRadius = newValue
//        }
//    }
//}
//extension String {
//    // Extracts the time string from HTML content
//    func extractTimeFromHTML() -> String? {
//        guard let startIndex = self.range(of: "title=\"")?.upperBound,
//              let endIndex = self.range(of: "\">", range: startIndex..<self.endIndex)?.lowerBound else {
//            return nil
//        }
//        let timeString = String(self[startIndex..<endIndex])
//        return timeString
//    }
//}
