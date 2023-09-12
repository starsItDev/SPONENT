//
//  LoginVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 10/08/2023.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - Variable
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotTextField: UITextField!
    @IBOutlet weak var forgotPasswordView: GradientView!
    let textFieldDelegateHelper = TextFieldDelegateHelper<LoginVC>()

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismiss()
        forgotTextField.layer.cornerRadius = 5
        forgotTextField.layer.borderWidth = 1.0
        forgotTextField.layer.borderColor = UIColor.black.cgColor
        forgotPasswordView.isHidden = true
  }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .portrait
  }
    
    //MARK: - HelperFuntions
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    
    //MARK: - Actions
     @IBAction func loginButton(_ sender: UIButton) {
        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                  tabBarController.modalPresentationStyle = .fullScreen
                  self.present(tabBarController, animated: false, completion: nil)
     }
}
    @IBAction func loginAsGuestButton(_ sender: Any) {
       if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: false, completion: nil)
        }
    }
    @IBAction func signUpButton(_ sender: UIButton) {
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: false)
        }
    }
    @IBAction func forgotPassword(_ sender: UIButton) {
        if forgotPasswordView.isHidden {
            forgotPasswordView.isHidden = false
        }
    }
    @IBAction func forgotCancelButton(_ sender: UIButton) {
        if forgotPasswordView.isHidden == false {
            forgotPasswordView.isHidden = true
        }
    }
}
