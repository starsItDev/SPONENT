//
//  ProfileVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/08/2023.
//

import UIKit
import Kingfisher

protocol ProfileDelegate: AnyObject {
    func didTapUserProfileSettingButton()
}

class ProfileVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - Variable
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileAboutLabel: UILabel!
    @IBOutlet weak var profileSegmentController: UISegmentedControl!
    @IBOutlet weak var profileSegmentView: UIView!
    @IBOutlet weak var profileActivityView: UIView!
    @IBOutlet weak var profileFollowerView: UIView!
    @IBOutlet weak var profileFollowingView: UIView!
    @IBOutlet weak var settingStackView: UIStackView!
    @IBOutlet weak var changePasswordView: GradientView!
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var userSettingStackView: UIStackView!
    @IBOutlet weak var imgProfileView: UIImageView!
    @IBOutlet weak var profileBackButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportNameLabel: UILabel!
    @IBOutlet weak var loctionLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ProfileVC>()
    weak var delegate: ProfileDelegate?
    let updateSignUpVC = UpdateSignUpVC()

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiCall()
        tabsApiCall()
    }
    //MARK: - API CAllING
    func apiCall() {
        let endpoint = APIConstants.Endpoints.appUser
        var urlString = APIConstants.baseURL + endpoint
        
        if let userId = UserDefaults.standard.string(forKey: "userID") {
            urlString += "?id=" + userId
        }
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        if let apikey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apikey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=7b88733d4b8336873c2371ae16760bf4ee9b5b9f", forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                // Handle the error as needed
            } else if let data = data {
                // Handle the API response here
                self.updateUI(with: data)
            }
        }
        
        task.resume()
    }
    func tabsApiCall(){
        let endpoint = APIConstants.Endpoints.tabsCount
        let urlString = APIConstants.baseURL + endpoint
        
//        if let userId = UserDefaults.standard.string(forKey: "userID") {
//            urlString += "?id=" + userId
//        }
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        if let apiKey = UserDefaults.standard.string(forKey: "apiKey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=7b88733d4b8336873c2371ae16760bf4ee9b5b9f", forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                self.updateCounters(with: data)
         }
      }
        task.resume()
    }
    func updateUI(with responseData: Data) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let body = jsonObject["body"] as? [String: Any] {
                
                DispatchQueue.main.async {
                    self.nameLabel.text = body["name"] as? String
                    self.ageLabel.text = body["age"] as? String
                    self.genderLabel.text = body["gender"] as? String
                    self.loctionLabel.text = body["location"] as? String
                    self.aboutMeLabel.text = body["about_me"] as? String
                    self.sportNameLabel.text = body["category_name"] as? String
                    if let avatarURLString = body["avatar"] as? String,
                        let avatarURL = URL(string: avatarURLString.replacingOccurrences(of: "http://", with: "https://")) {
                        self.imgProfileView.kf.setImage(with: avatarURL, placeholder: UIImage(named: "placeholderImage"), options: nil, completionHandler: { result in
                        switch result {
                            case .success(let value):
                                print("Image loaded successfully: \(value.image)")
                            case .failure(let error):
                                print("Error loading image: \(error)")
                            }
                        })
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    func updateCounters(with responseData: Data) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let body = jsonObject["body"] as? [String: Any] {
                DispatchQueue.main.async {
                    let activitiesCount = body["activities"] as? Int ?? 0
                    let followersCount = body["followers"] as? Int ?? 0
                    let followingCount = body["followings"] as? Int ?? 0
                    
                    self.profileSegmentController.setTitle("Activities: \(activitiesCount)", forSegmentAt: 1)
                    self.profileSegmentController.setTitle("Followers: \(followersCount)", forSegmentAt: 2)
                    self.profileSegmentController.setTitle("Following: \(followingCount)", forSegmentAt: 3)

                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    //MARK: - Actions
    @IBAction func profileSegmentControl(_ sender: UISegmentedControl) {
        switch profileSegmentController.selectedSegmentIndex {
        case 0:
            profileSegmentView.isHidden = false
            profileActivityView.isHidden = true
            profileFollowerView.isHidden = true
            profileFollowingView.isHidden = true
        case 1:
            profileSegmentView.isHidden = true
            profileActivityView.isHidden = false
            profileFollowerView.isHidden = true
            profileFollowingView.isHidden = true
        case 2:
            profileSegmentView.isHidden = true
            profileActivityView.isHidden = true
            profileFollowerView.isHidden = false
            profileFollowingView.isHidden = true
        case 3:
            profileSegmentView.isHidden = true
            profileActivityView.isHidden = true
            profileFollowerView.isHidden = true
            profileFollowingView.isHidden = false
        default:
            break
        }
    }
    @IBAction func profileSettingButton(_ sender: UIButton) {
        if settingStackView.isHidden {
            settingStackView.isHidden = false
        } else {
            settingStackView.isHidden = true
        }
        delegate?.didTapUserProfileSettingButton()
    }
    @IBAction func editProfileButton(_ sender: UIButton) {
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateSignUpVC") as? UpdateSignUpVC {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: false)
        }
    }
    @IBAction func changePasswordButton(_ sender: UIButton) {
        if changePasswordView.isHidden {
                changePasswordView.isHidden = false
                settingStackView.isHidden = true
        }
    }
    @IBAction func signOutButton(_ sender: UIButton) {
        UserDefaults.standard.set("", forKey: "userID")
        UserDefaults.standard.set("", forKey: "apikey")
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    @IBAction func updateCancelButton(_ sender: UIButton) {
        if !changePasswordView.isHidden {
            changePasswordView.isHidden = true
        }
    }

    @IBAction func updateOkButton(_ sender: UIButton) {
        if let oldPassword = oldPasswordField.text,
           let newPassword = newPasswordField.text,
           let confirmPassword = confirmPasswordField.text {
            
            if oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
                showAlert(title: "Alert", message: "Please fill in all text fields.")
            } else {
                let parameters = [
                    [
                        "key": "newPassword",
                        "value": newPassword,
                        "type": "text"
                    ],
                    [
                        "key": "oldPassword",
                        "value": oldPassword,
                        "type": "text"
                    ]
                ]
                
                // Create the multipart form data request body
                let boundary = "Boundary-\(UUID().uuidString)"
                var body = Data()
                
                for param in parameters {
                    if let disabled = param["disabled"] as? Bool, disabled {
                        continue
                    }
                    let paramName = param["key"] as! String
                    let paramType = param["type"] as! String
                    
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"\(paramName)\"".data(using: .utf8)!)
                    
                    if paramType == "text" {
                        let paramValue = param["value"] as! String
                        body.append("\r\n\r\n\(paramValue)\r\n".data(using: .utf8)!)
                    } else {
                        if let paramSrc = param["src"] as? String {
                            do {
                                let fileData = try Data(contentsOf: URL(fileURLWithPath: paramSrc))
                                body.append("; filename=\"\(paramSrc)\"\r\n".data(using: .utf8)!)
                                body.append("Content-Type: \"content-type header\"\r\n\r\n".data(using: .utf8)!)
                                body.append(fileData)
                                body.append("\r\n".data(using: .utf8)!)
                            } catch {
                                print("Error reading file: \(error)")
                            }
                        }
                    }
                }
                
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                
                let endpoint = APIConstants.Endpoints.updatePassword
                let urlString = APIConstants.baseURL + endpoint
                
                guard let url = URL(string: urlString) else {
                    showAlert(title: "Alert", message: "Invalid URL")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                
                if let apikey = UserDefaults.standard.string(forKey: "apikey") {
                    request.addValue(apikey, forHTTPHeaderField: "authorizuser")
                }
                
                request.addValue("ci_session=5f00cf86613afada367b19f16bfcef515914c5a7", forHTTPHeaderField: "Cookie")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error)")
                    } else if let data = data {
                        print(String(data: data, encoding: .utf8)!)
                    DispatchQueue.main.async {
                            self.changePasswordView.isHidden = true
                        }
                    }
                }
                task.resume()
            }
        } else {
            showAlert(title: "Alert", message: "Please fill in all text fields.")
        }
    }


    //MARK: - Helper Functions
    func uiSetUp(){
        profileSegmentView.isHidden = false
        profileActivityView.isHidden = true
        profileFollowerView.isHidden = true
        profileFollowingView.isHidden = true
        settingStackView.isHidden = true
        userSettingStackView.isHidden = true
        changePasswordView.isHidden = true
        followButton.isHidden = true
        profileBackButton.isHidden = true
        oldPasswordField.layer.cornerRadius = 5
        oldPasswordField.layer.borderWidth = 1.0
        oldPasswordField.layer.borderColor = UIColor.gray.cgColor
        newPasswordField.layer.cornerRadius = 5
        newPasswordField.layer.borderWidth = 1.0
        newPasswordField.layer.borderColor = UIColor.gray.cgColor
        confirmPasswordField.layer.cornerRadius = 5
        confirmPasswordField.layer.borderWidth = 1.0
        confirmPasswordField.layer.borderColor = UIColor.gray.cgColor
        setupKeyboardDismiss()
        self.navigationController?.navigationBar.isHidden = true
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
}
