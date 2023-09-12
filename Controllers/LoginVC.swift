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
            showAlert(title: "Alert", message: "Please enter both username and password")
            return
        }

        let parameters = [
            "email" : username,
            "password": password
        ] as Dictionary<String, Any>

        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters)
            let endpoint = APIConstants.Endpoints.login
            let urlString = APIConstants.baseURL + endpoint

            guard let url = URL(string: urlString) else {
                showAlert(title: "Alert", message: "Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to fetch data from the server.")
                    }
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Response JSON: \(json)")

                        if let code = json["code"] as? Int, code == 201,
                           let body = json["body"] as? [String: Any],
                           let message = body["message"] as? String {
                            // Handle the specific error message returned by the API
                            DispatchQueue.main.async {
                                self.showAlert(title: "Alert", message: message)
                            }
                        } else if let status = json["Status"] as? Bool, status {
                            DispatchQueue.main.async {
                                if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                                    tabBarController.modalPresentationStyle = .fullScreen
                                    self.present(tabBarController, animated: false, completion: nil)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Alert", message: "Invalid username or password")
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to parse server response.")
                    }
                }
            }.resume()
        } catch {
            print("Error creating JSON data: \(error)")
            showAlert(title: "Error", message: "Failed to create JSON data.")
        }
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
