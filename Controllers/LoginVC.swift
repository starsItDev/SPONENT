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

    //MARK: - Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetUp()
  }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .portrait
  }
    
    //MARK: - HelperFuntions
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    func uiSetUp() {
        setupKeyboardDismiss()
        forgotTextField.layer.cornerRadius = 5
        forgotTextField.layer.borderWidth = 1.0
        forgotTextField.layer.borderColor = UIColor.black.cgColor
        forgotPasswordView.isHidden = true
    }
    // MARK: - POST API Calling
    func apiCall() {
        guard let username = EmailTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Alert", message: "Please enter both Email and Password")
            return
        }
        let parameters = [
            "email" : username,
            "password": password
        ]
        // Create the multipart form data request body
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for (key, value) in parameters {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            body += "\(value)\r\n"
        }

        let endpoint = APIConstants.Endpoints.login
        let urlString = APIConstants.baseURL + endpoint

        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to fetch data from the server.")
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                            tabBarController.modalPresentationStyle = .fullScreen
                            self.present(tabBarController, animated: false, completion: nil)
                        }
                    } else {
                        // HTTP status code is not 200, show an alert for the error
                        self.showAlert(title: "Error", message: "Invalid Email or Password")
                    }
                }
            }
        }.resume()

    }
    //MARK: - Actions
    @IBAction func loginButton(_ sender: UIButton) {
        apiCall()
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
