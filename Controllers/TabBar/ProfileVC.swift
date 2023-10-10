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
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportNameLabel: UILabel!
    @IBOutlet weak var loctionLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ProfileVC>()
    var delegate: ProfileDelegate?
    let updateSignUpVC = UpdateSignUpVC()
    var isProfileBackButtonHidden = true
    var isFollowButtonHidden = true
    var receiverID: String?
    
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
        
        if let receiverID = receiverID {
                urlString += "?id=" + receiverID
            } else if let userID = UserDefaults.standard.string(forKey: "userID") {
                urlString += "?id=" + userID
            } else {
                showAlert(title: "Alert", message: "Both receiverID and userID are missing")
                return
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
            } else if let data = data {
                self.updateUI(with: data)
            }
        }
        
        task.resume()
    }
    func tabsApiCall(){
        let endpoint = APIConstants.Endpoints.tabsCount
        var urlString = APIConstants.baseURL + endpoint
        
        if let receiverID = receiverID {
               urlString += "?id=" + receiverID
           }
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
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
                    if let avatarURLString = body["avatar"] as? String {
                        self.loadImage(from: avatarURLString, into: self.imgProfileView, placeholder: UIImage(named: "placeholderImage"))
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
    func blockapiCall() {
        let endpoint = APIConstants.Endpoints.blockUser
        let urlString = APIConstants.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let parameters = [
            [
                "key": "user_id",
                "value": receiverID!,
                "type": "text"
            ],
        ] as [[String: Any]]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.setValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        for param in parameters {
            let paramName = param["key"] as! String
            let paramValue = param["value"] as! String
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(paramValue)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseData = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseData)")
                DispatchQueue.main.async {
                    self.blockButton.setTitle("Blocked", for: .normal)
                    self.showAlert(title: "Unblock", message: responseData)
                }
            }
        }
        task.resume()
    }
    func unblockUser() {
        let endpoint = APIConstants.Endpoints.userUnblock
        let urlString = APIConstants.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let parameters = [
            [
                "key": "user_id",
                "value": receiverID!,
                "type": "text"
            ],
        ] as [[String: Any]]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.setValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        for param in parameters {
            let paramName = param["key"] as! String
            let paramValue = param["value"] as! String
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(paramValue)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseData = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseData)")
                DispatchQueue.main.async {
                    self.blockButton.setTitle("Blocked", for: .normal)
                    self.showAlert(title: "Unblock", message: responseData)
                }
            }
        }
        task.resume()
    }
    func reportApiCall() {
        let endpoint = APIConstants.Endpoints.userReport
        let urlString = APIConstants.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let parameters = [
          [
            "key": "type",
            "value": "Spam",
            "type": "text"
          ],
          [
            "key": "description",
            "value": "test",
            "type": "text"
          ],
          [
            "key": "user_id",
            "value": receiverID!,
            "type": "text"
          ]] as [[String: Any]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.setValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        for param in parameters {
            let paramName = param["key"] as! String
            let paramValue = param["value"] as! String
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(paramValue)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseData = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseData)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Report", message: responseData)
                }
            }
        }
        task.resume()
    }
    func friendshipAddAPI() {
        let endpoint = APIConstants.Endpoints.friendshipAdd
        let urlString = APIConstants.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let parameters = [
          [
            "key": "friendId",
            "value": receiverID!,
            "type": "text"
          ]] as [[String: Any]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.setValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        for param in parameters {
            let paramName = param["key"] as! String
            let paramValue = param["value"] as! String
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(paramValue)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseData = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseData)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Friend Add", message: responseData)
                }
            }
        }
        task.resume()
    }
    func friendshipLeaveAPI() {
        let endpoint = APIConstants.Endpoints.friendshipLeave
        let urlString = APIConstants.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let parameters = [
          [
            "key": "friendId",
            "value": receiverID!,
            "type": "text"
          ]] as [[String: Any]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.setValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        for param in parameters {
            let paramName = param["key"] as! String
            let paramValue = param["value"] as! String
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(paramValue)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseData = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseData)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Leave Frined", message: responseData)
                }
            }
        }
        task.resume()
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
        guard let oldPassword = oldPasswordField.text,
              let newPassword = newPasswordField.text,
              let confirmPassword = confirmPasswordField.text,
              !oldPassword.isEmpty,
              !newPassword.isEmpty,
              !confirmPassword.isEmpty else {
                showAlert(title: "Alert", message: "Please fill in all text fields.")
                return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        let parameters = [
            ["key": "newPassword", "value": newPassword],
            ["key": "oldPassword", "value": oldPassword]
        ]
        
        for param in parameters {
            let paramName = param["key"]!
            let paramValue = param["value"]!
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(paramValue)\r\n".data(using: .utf8)!)
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
    @IBAction func followButton(_ sender: UIButton) {
        if followButton.currentTitle == "Follow" {
            followButton.setTitle("Unfollow", for: .normal)
            friendshipAddAPI()
        } else {
            followButton.setTitle("Follow", for: .normal)
            friendshipLeaveAPI()
        }
    }
    @IBAction func ProfileBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func blockButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "Block" {
            blockapiCall()
        } else if sender.titleLabel?.text == "Unblock" {
            unblockUser()
        }
    }
    @IBAction func reportButton(_ sender: UIButton) {
        reportApiCall()
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
        profileBackButton.isHidden = isProfileBackButtonHidden
        followButton.isHidden = isFollowButtonHidden
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
