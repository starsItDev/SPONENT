//
//  LoginVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 10/08/2023.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class LoginVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - Variable
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotTextField: UITextField!
    @IBOutlet weak var forgotPasswordView: GradientView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var transparentView: GradientView!
    @IBOutlet weak var loginPasswdEye: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var socialStackView: UIStackView!
    @IBOutlet weak var appleSignIn: ASAuthorizationAppleIDButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginGuest: UIButton!
    let textFieldDelegateHelper = TextFieldDelegateHelper<LoginVC>()
    var socialEmail: String?
    var socialName: String?

    //MARK: - Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        uiSetUp()
        EmailTextField.delegate = self
        passwordTextField.delegate = self
        appleSignIn.addTarget(self, action: #selector(appleBtnTapped), for: .touchUpInside)
        customizeAppleSignInButton()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: - HelperFuntions
    func facebookLogin() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .cancelled:
                print("cancelled")
            case .failed(let error):
                print(error.localizedDescription)
            case .success(_, _, _):
                self.getFBData()
            }
        }
    }
    func getFBData() {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"]).start {
                (connection, result, error) in
                if error == nil {
                    let result = result as! [String: AnyObject] as NSDictionary
                    self.socialName = result.object(forKey: "name") as? String
                    self.socialEmail = result.object(forKey: "email") as? String
                    let id = result.object(forKey: "id") as! String
                    let type = "facebook"
                    let pushId = ""
                    let pushType = "ios"
                    
                    let fbParameters: [String: Any] = [
                        "id": id ,
                       "type": type,
                       "pushId": pushId,
                       "pushType": pushType
                   ]
                    self.SocialapiCall(parameters: fbParameters)

                } else {
                    print(error?.localizedDescription as Any)
               }
            }
        } else {
            print("access token is nil")
        }
    }
    func customizeAppleSignInButton() {
        let appleSignInButton = UIButton(type: .custom)
        let appleLogoImage = UIImage(named: "icons8-apple-logo-48")
        appleSignInButton.setBackgroundImage(appleLogoImage, for: .normal)
        appleSignInButton.addTarget(self, action: #selector(appleBtnTapped), for: .touchUpInside)
        socialStackView.addArrangedSubview(appleSignInButton)
        appleSignIn.isHidden = true
    }
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
    func ValidationCode() {
        if let email = EmailTextField.text, let password = passwordTextField.text {
            if email == "" {
                showAlert(title: "Alert", message: "Please enter email")
            }
            else if !email.validateEmailId() {
                showAlert(title: "Alert", message: "Please enter correct email")
            }
            else if password == "" {
                showAlert(title: "Alert", message: "Please enter password")
            }
            else if password.count < 6 {
                showAlert(title: "Alert", message: "Password should be at least 6 characters")
            }
            else {
                apiCall()
            }
        }
    }
    @objc func appleBtnTapped() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.performRequests()
    }

    // MARK: - API Calling
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
                    self.showAlert(title: "Error", message: "Please check your internet connection")
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
                                    UserDefaults.standard.set(password, forKey: "password")
                                    print(apikey)
                                    self.signInSuccessful()
                                   UserInfo.shared.isUserLoggedIn = true
//                                    if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
//                                        tabBarController.modalPresentationStyle = .fullScreen
//                                        self.present(tabBarController, animated: false, completion: nil)
//                                    }
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
    func signInSuccessful() {
        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
            }
        }
    }

    func SocialapiCall(parameters: [String: Any]) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        
        for (key, value) in parameters {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            body += "\(value)\r\n"
        }
        
        let endpoint = APIConstants.Endpoints.socialLogin
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
                    } else if httpResponse.statusCode == 201 {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                let body = json["body"] as? [String: Any]
                                if let userExist = body?["userExist"] as? Bool,
                                  userExist == false {
                                    if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
                                            vc.name = self.socialName
                                            vc.email = self.socialEmail
                                            vc.isSocialLogin = true
                                            vc.socialID = parameters["id"] as? String
                                            vc.socialType = parameters["type"] as? String
                                        
                                            vc.modalPresentationStyle = .fullScreen
                                            self.present(vc, animated: false, completion: nil)
                                    }
                                } else if let userId = body?["user_id"] as? String,
                                          let apikey = body?["apikey"] as? String {
                                    UserDefaults.standard.set(userId, forKey: "userID")
                                    UserDefaults.standard.set(apikey, forKey: "apikey")
                                }
                            }
                        }
                          else {
                            self.showAlert(title: "Error", message: "SignIn Failed")
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
        if !forget.validateEmailId() {
            showAlert(title: "Alert", message: "Please enter correct email")
            return
        } else {
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
                        self.transparentView.isHidden = true
                        self.forgotTextField.text = ""
                    }
                }
            }
        }
        task.resume()
      }
    }
    @IBAction func loginButton(_ sender: UIButton) {
        ValidationCode()
    }
    @IBAction func loginAsGuestButton(_ sender: Any) {
        EmailTextField.text = "guest@starsfun.com"
        passwordTextField.text = "123786un"
        apiCall()
        UserDefaults.standard.set("", forKey: "userID")
        UserDefaults.standard.set("", forKey: "apikey")
    }
    @IBAction func signUpButton(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    @IBAction func facebookBtn(_ sender: UIButton) {
        self.facebookLogin()
    }
    @IBAction func forgotPassword(_ sender: UIButton) {
        if forgotPasswordView.isHidden {
            forgotPasswordView.isHidden = false
            transparentView.isHidden = false
        }
    }
    @IBAction func forgotCancelButton(_ sender: UIButton) {
        if forgotPasswordView.isHidden == false {
            transparentView.isHidden = true
            forgotPasswordView.isHidden = true
        }
    }
    @IBAction func googleBtnTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            self.socialEmail = user.profile?.email
            self.socialName = user.profile?.name
            let id = user.userID
            let type = "google"
            let pushId = ""
            let pushType = "ios"
            
            let parameters = [
                "id": id ?? "",
                "type": type,
                "pushId": pushId,
                 "pushType": pushType
                ] as [String: Any]

                self.SocialapiCall(parameters: parameters)
        }
    }
    @IBAction func loginEyeBtn(_ sender: UIButton) {
        if passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = false
            let eyeImage = UIImage(systemName: "eye")
            loginPasswdEye.setImage(eyeImage, for: .normal)
            loginPasswdEye.tintColor = .white
        } else {
            passwordTextField.isSecureTextEntry = true
            let eyeSlashImage = UIImage(systemName: "eye.slash")
            loginPasswdEye.setImage(eyeSlashImage, for: .normal)
            loginPasswdEye.tintColor = .white
        }
    }
}

//MARK: - Apple button delegate
extension LoginVC: ASAuthorizationControllerDelegate{
   func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
         if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
             let formatter = PersonNameComponentsFormatter()
             let fullName = appleIDCredential.fullName
             self.socialName = formatter.string(from: fullName!)
             self.socialEmail = appleIDCredential.email
             let id = appleIDCredential.user
             let type = "apple"
             let pushId = ""
             let pushType = "ios"
        
         let appleParameters = [
             "id": id,
             "type": type,
             "pushId": pushId,
              "pushType": pushType
             ] as [String: Any]
             
             self.SocialapiCall(parameters: appleParameters)
      }
   }
   func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
     print("Failed!")
   }
}
