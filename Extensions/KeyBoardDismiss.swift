//
//  KeyBoardDismiss.swift
//  SPONENT
//
//  Created by Rao Ahmad on 07/09/2023.
//

import Foundation
import UIKit

class TextFieldDelegateHelper<ViewControllerType: UIViewController>: NSObject, UITextFieldDelegate {

    var tapGesture: UITapGestureRecognizer?

    func configureTapGesture(for view: UIView, in viewController: ViewControllerType) {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture?.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(tapGesture!)
    }

    func removeTapGesture(from view: UIView) {
        view.removeGestureRecognizer(tapGesture!)
        tapGesture = nil
    }

    @objc func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
