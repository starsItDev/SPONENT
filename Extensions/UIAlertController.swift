//
//  AlertController.swift
//  SPONENT
//
//  Created by Rao Ahmad on 23/08/2023.
//

import UIKit

extension UIViewController {
    
    func presentActionSheet(title: String?, message: String?, actions: [UIAlertAction], sourceView: UIView?, sourceRect: CGRect?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // Check if running on iPad
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sourceView ?? view
            popoverController.sourceRect = sourceRect ?? CGRect(x: 0, y: 0, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        for action in actions {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(title: String?, message: String?,completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func showAlert(title: String?,
                   message: String?,
                   preferredStyle: UIAlertController.Style = .alert,
                   actions: [UIAlertAction] = [],
                   defaultActionTitle: String? = "OK",
                   completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            actions.forEach { alertController.addAction($0) }
            
            if actions.isEmpty, let defaultActionTitle = defaultActionTitle {
                let okAction = UIAlertAction(title: defaultActionTitle, style: .default, handler: nil)
                alertController.addAction(okAction)
            }
            
            self.present(alertController, animated: true, completion: completion)
        }
    }
}
