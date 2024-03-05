//
//  ShowToastView.swift
//  SPONENT
//
//  Created by Rao Ahmad on 29/02/2024.
//

import Foundation
import UIKit

class ToastView: UIView {
    private let messageLabel: UILabel
    
    init(message: String) {
        messageLabel = UILabel()
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        messageLabel.text = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 10
        clipsToBounds = true
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)
    }
    private func setupConstraints() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastView = ToastView(message: message)
        view.addSubview(toastView)
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -130),
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        UIView.animate(withDuration: 0.5, animations: {
            toastView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: duration, delay: 0.5, animations: {
                toastView.alpha = 0.0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}
