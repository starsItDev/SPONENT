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
        forgotTextField.layer.borderColor = UIColor.lightGray.cgColor
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "Error", message: "Failed to fetch data from the server.")
                    return
                }
                guard let data = data else {
                    print("Data not received.")
                    return
                }
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                let body = json["body"] as? [String: Any]
                                if let userId = body?["user_id"] as? String,
                                   let apikey = body?["apikey"] as? String {
                                    UserDefaults.standard.set(userId, forKey: "userID")
                                    UserDefaults.standard.set(apikey, forKey: "apikey")
                                    print(apikey)
                                    
                                    if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                                        tabBarController.modalPresentationStyle = .fullScreen
                                        self.present(tabBarController, animated: false, completion: nil)
                                    }
                                }
                            }
                        } else {
                            self.showAlert(title: "Error", message: "Invalid Email or Password")
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }.resume()
    }
    //MARK: - Actions
    @IBAction func forgotOkayButton(_ sender: UIButton) {
        guard let forget = forgotTextField.text, !forget.isEmpty else {
            showAlert(title: "Alert", message: "Please enter Email")
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        let parameters = [
            ("email", forget, "text")
        ]
        
        for (key, value, _) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let endpoint = APIConstants.Endpoints.resetPassword
        let urlString = APIConstants.baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("ci_session=5108c3896d21bcd6f8b4b7cd61f7a4472b9b0546", forHTTPHeaderField: "Cookie")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Password Reset", message: "Please login to your email to get new password.")
                        self.forgotPasswordView.isHidden = true
                    }
                }
            }
        }
        task.resume()
    }

    @IBAction func loginButton(_ sender: UIButton) {
        apiCall()
    }
    @IBAction func loginAsGuestButton(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "userID")
        UserDefaults.standard.set("", forKey: "apikey")
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
