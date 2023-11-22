//
//  ProfileVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/08/2023.
//

import UIKit
import Kingfisher
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import FBSDKLoginKit

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
    @IBOutlet weak var profileActivityTableView: UITableView!
    @IBOutlet weak var profileFollowerTableView: UITableView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var profileFollowingTableView: UITableView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportNameLabel: UILabel!
    @IBOutlet weak var loctionLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var profileImgView: UIView!
    @IBOutlet weak var transparenView: UIView!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ProfileVC>()
    var delegate: ProfileDelegate?
    let updateSignUpVC = UpdateSignUpVC()
    var isProfileBackButtonHidden = true
    var isFollowButtonHidden = true
    var issettingViewHidden = false
    var isUserSettingViewHidden = true
    var receiverID: String?
    var userFollowStatus: [String: Bool] = [:]
    var userBlockStatus: [String: Bool] = [:]
    var activity: [Activities] = []
    var followers: [Follower] = []
    var followings: [Following] = []
    var selectedReceiverID: String?
    var selectedMarker: GMSMarker?
    var selectedLocationLatitude: Double?
    var selectedLocationLongitude: Double?
    var labelText: String?
    var dismissViewTap: UITapGestureRecognizer?
    var categoryID: Int?

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        followingAPICall()
        uiSetUp()
        getActivityAPiCall()
        updateFollowButtonTitle()
        updateBlockButtonTitle()
        followerAPICall()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiCall()
        settingStackView.isHidden = true
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
                    self.categoryID = body["category_id"] as? Int
                    if let avatarURLString = body["avatar"] as? String {
                        self.loadImage(from: avatarURLString, into: self.imgProfileView)
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
                    
                    self.profileSegmentController.setTitle("Activities(\(activitiesCount))", forSegmentAt: 1)
                    self.profileSegmentController.setTitle("Followers(\(followersCount))", forSegmentAt: 2)
                    self.profileSegmentController.setTitle("Following(\(followingCount))", forSegmentAt: 3)

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
                "value": receiverID ?? "",
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
                    //self.blockButton.setTitle("Unblock", for: .normal)
                    self.showAlert(title: "Blocked User", message: responseData)
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
                "value": receiverID ?? "",
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
                    self.showAlert(title: "Unblocked User", message: responseData)
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
            "value": receiverID ?? "",
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
                    self.showAlert(title: "Alert", message: responseData)
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
            "value": receiverID ?? "",
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
            "value": receiverID ?? "",
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
        settingStackView.isHidden = true
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
            getActivityAPiCall()
        case 2:
            profileSegmentView.isHidden = true
            profileActivityView.isHidden = true
            profileFollowerView.isHidden = false
            profileFollowingView.isHidden = true
            followingAPICall()
        case 3:
            profileSegmentView.isHidden = true
            profileActivityView.isHidden = true
            profileFollowerView.isHidden = true
            profileFollowingView.isHidden = false
            followingAPICall()
        default:
            break
        }
    }
    @IBAction func profileSettingButton(_ sender: UIButton) {
        settingStackView.isHidden = issettingViewHidden
        userSettingStackView.isHidden = isUserSettingViewHidden
        delegate?.didTapUserProfileSettingButton()
    }
    @IBAction func editProfileButton(_ sender: UIButton) {
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateSignUpVC") as? UpdateSignUpVC {
            settingStackView.isHidden = true
            controller.modalPresentationStyle = .fullScreen
            var userProfileData = UserProfileData()
            userProfileData.profileImage = imgProfileView.image
            userProfileData.name = nameLabel.text
            userProfileData.age = ageLabel.text
            userProfileData.gender = genderLabel.text
            userProfileData.category = sportNameLabel.text
            userProfileData.aboutMe = aboutMeLabel.text
            userProfileData.categoryID = self.categoryID
            controller.userProfileData = userProfileData
            self.present(controller, animated: false)
        }
    }
    @IBAction func changePasswordButton(_ sender: UIButton) {
        if changePasswordView.isHidden {
            changePasswordView.isHidden = false
            transparenView.isHidden = false
            settingStackView.isHidden = true
        }
    }
    @IBAction func signOutButton(_ sender: UIButton) {
        UserDefaults.standard.set("", forKey: "userID")
        UserDefaults.standard.set("", forKey: "apikey")
        UserDefaults.standard.set("", forKey: "password")
        let loginManager = LoginManager()
        loginManager.logOut()
        GIDSignIn.sharedInstance.signOut()
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    @IBAction func updateCancelButton(_ sender: UIButton) {
        if !changePasswordView.isHidden {
            changePasswordView.isHidden = true
            transparenView.isHidden = true
            oldPasswordField.text = ""
            newPasswordField.text = ""
            confirmPasswordField.text = ""
        }
    }
    @IBAction func updateOkButton(_ sender: UIButton) {
        if let oldPassword = oldPasswordField.text,
        let newPassword = newPasswordField.text,
           let confirmPassword = confirmPasswordField.text {

               if oldPassword == "" || newPassword == "" || confirmPassword == "" {
                  
                   if oldPassword == "" {
                       oldPasswordField.layer.borderColor = UIColor.red.cgColor
                   }
                   if newPassword == "" {
                       newPasswordField.layer.borderColor = UIColor.red.cgColor
                   }
                   if confirmPassword == "" {
                       confirmPasswordField.layer.borderColor = UIColor.red.cgColor
                   }
                   showAlert(title: "Alert", message: "Please fill in all required fields")
               } else {
                   if let storedPassword = UserDefaults.standard.string(forKey: "password"), oldPassword != storedPassword {
                            oldPasswordField.layer.borderColor = UIColor.red.cgColor
                            showAlert(title: "Alert", message: "Incorrect old password")
                        return
               }
                   oldPasswordField.layer.borderColor = UIColor.lightGray.cgColor
                   newPasswordField.layer.borderColor = UIColor.lightGray.cgColor
                   confirmPasswordField.layer.borderColor = UIColor.lightGray.cgColor
                   
                   if newPassword.count < 6 {
                       newPasswordField.layer.borderColor = UIColor.red.cgColor
                       showAlert(title: "Alert", message: "Password should be at least 6 characters")
                       return
                   } else {
                       newPasswordField.layer.borderColor = UIColor.lightGray.cgColor
                   }
                   if confirmPassword.count < 6 {
                       confirmPasswordField.layer.borderColor = UIColor.red.cgColor
                       showAlert(title: "Alert", message: "Confirm password should be at least 6 characters")
                       return
                   } else {
                       confirmPasswordField.layer.borderColor = UIColor.lightGray.cgColor
                   }
                   if newPassword != confirmPassword {
                       newPasswordField.layer.borderColor = UIColor.red.cgColor
                       confirmPasswordField.layer.borderColor = UIColor.red.cgColor
                       showAlert(title: "Alert", message: "Both passwords should be the same")
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
                    self.transparenView.isHidden = true
                    self.showAlert(title: "Alert", message: "Password changed successfully")
                }
            }
        }
        task.resume()
      }
   }
}
    @IBAction func followButton(_ sender: UIButton) {
        if let userID = receiverID {
            if userFollowStatus[userID] == true {
                followButton.setTitle("Follow", for: .normal)
                userFollowStatus[userID] = false
                UserDefaults.standard.set(false, forKey: "FollowStatus_\(userID)")
                friendshipLeaveAPI()
            } else {
                followButton.setTitle("Unfollow", for: .normal)
                userFollowStatus[userID] = true
                UserDefaults.standard.set(true, forKey: "FollowStatus_\(userID)")
                friendshipAddAPI()
            }
        }
    }
    @IBAction func ProfileBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func blockButton(_ sender: UIButton) {
        if let userID = receiverID {
            if userBlockStatus[userID] == true {
                unblockUser()
                userBlockStatus[userID] = false
                blockButton.setTitle("Block", for: .normal)
                UserDefaults.standard.set(false, forKey: "BlockStatus_\(userID)")
            } else {
                blockapiCall()
                userBlockStatus[userID] = true
                blockButton.setTitle("Unblock", for: .normal)
                UserDefaults.standard.set(true, forKey: "BlockStatus_\(userID)")
            }
        }
        userSettingStackView.isHidden = true
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
        oldPasswordField.delegate = self
        newPasswordField.delegate = self
        confirmPasswordField.delegate = self
        oldPasswordField.layer.cornerRadius = 5
        oldPasswordField.layer.borderWidth = 1.0
        oldPasswordField.layer.borderColor = UIColor.gray.cgColor
        newPasswordField.layer.cornerRadius = 5
        newPasswordField.layer.borderWidth = 1.0
        newPasswordField.layer.borderColor = UIColor.gray.cgColor
        confirmPasswordField.layer.cornerRadius = 5
        confirmPasswordField.layer.borderWidth = 1.0
        confirmPasswordField.layer.borderColor = UIColor.gray.cgColor
        profileSegmentController.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
        if let labelText = labelText {
            myProfileLabel.text = labelText
        }
        setupKeyboardDismiss()
        self.navigationController?.navigationBar.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        profileSegmentView.addGestureRecognizer(tap)
        let tapTwo = UITapGestureRecognizer(target: self, action: #selector(self.handleTapTwo(_:)))
        profileImgView.addGestureRecognizer(tapTwo)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        settingStackView.isHidden = true
        userSettingStackView.isHidden = true
    }
    @objc func handleTapTwo(_ sender: UITapGestureRecognizer? = nil) {
        settingStackView.isHidden = true
        userSettingStackView.isHidden = true
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    func updateFollowButtonTitle() {
        if let userID = receiverID {
            let followStatus = UserDefaults.standard.bool(forKey: "FollowStatus_\(userID)")
            userFollowStatus[userID] = followStatus
            if followStatus {
                followButton.setTitle("Unfollow", for: .normal)
            } else {
                followButton.setTitle("Follow", for: .normal)
            }
        }
    }
    func updateBlockButtonTitle() {
        if let userID = receiverID {
            let blockStatus = UserDefaults.standard.bool(forKey: "BlockStatus_\(userID)")
            userBlockStatus[userID] = blockStatus
            if blockStatus {
                blockButton.setTitle("Unblock", for: .normal)
            } else {
                blockButton.setTitle("Block", for: .normal)
            }
        }
    }
//    func didSelectLocation(_ locationName: String) {
//        let geocoder = CLGeocoder()
//           geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
//               if let placemark = placemarks?.first, let locationCoordinate = placemark.location?.coordinate {
//                   self?.selectedLocationLatitude = locationCoordinate.latitude
//                   self?.selectedLocationLongitude = locationCoordinate.longitude
//            }
//        }
//    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == oldPasswordField {
            oldPasswordField.layer.borderColor = UIColor.lightGray.cgColor
        } else if textField == newPasswordField {
            newPasswordField.layer.borderColor = UIColor.lightGray.cgColor
        } else if textField == confirmPasswordField {
            confirmPasswordField.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}

//MARK: - Extension TableView
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == profileActivityTableView {
            return activity.count
        } else if tableView == profileFollowerTableView {
            return followers.count
        } else if tableView == profileFollowingTableView {
            return followings.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == profileActivityTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileActivityCell
            let activities = activity[indexPath.row]
            cell.nameLabel?.text = activities.ownerTitle
            cell.activityTitle?.text = activities.activity
            cell.dateLabel?.text = activities.date
            cell.timeLabel?.text = activities.time
            cell.activityTableLocation?.text = activities.location
            loadImage(from: activities.catAvatar, into: cell.catAvatarImage)
            loadImage(from: activities.avatar, into: cell.activityTableImage)
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
             return cell
        } else if tableView == profileFollowerTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileFollowerCell
            let follower = followers[indexPath.row]
            cell.followerNameLabel?.text = follower.title
            loadImage(from: follower.photoURL, into: cell.followerImageView)
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
            return cell
        } else if tableView == profileFollowingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileFollowingCell
            let following = followings[indexPath.row]
            cell.followingNameLabel?.text = following.title
            loadImage(from: following.photoURL, into: cell.followingImageView)
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == profileActivityTableView {
              let defaultHeight: CGFloat = 99.0
              let cell = tableView.cellForRow(at: indexPath) as? ProfileActivityCell
              if let cell = cell {
                  let labelHeight = cell.activityTableLocation.intrinsicContentSize.height
                  if labelHeight > defaultHeight {
                      return UITableView.automaticDimension
                  }
              }
              return defaultHeight
          } else if tableView == profileFollowerTableView {
               return 99
            } else if tableView == profileFollowingTableView {
                 return 99
             }
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == profileFollowerTableView {
            let follower = followers[indexPath.row]
            selectedReceiverID = follower.userID
          if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
              vc.isProfileBackButtonHidden = false
              vc.isFollowButtonHidden = false
              vc.receiverID = follower.userID
              vc.issettingViewHidden = true
              vc.isUserSettingViewHidden = false
              let selectedText = "Profile"
              vc.labelText = selectedText
              self.navigationController?.pushViewController(vc, animated: true)
          }
        } else if tableView == profileFollowingTableView {
            let following = followings[indexPath.row]
            selectedReceiverID = following.userID
             if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                 vc.isProfileBackButtonHidden = false
                 vc.isFollowButtonHidden = false
                 vc.receiverID = following.userID
                 vc.issettingViewHidden = true
                 vc.isUserSettingViewHidden = false
                 let selectedText = "Profile"
                 vc.labelText = selectedText
                 self.navigationController?.pushViewController(vc, animated: true)
             }
         } else if tableView == profileActivityTableView {
             let activity = activity[indexPath.row]
             if let cell = tableView.cellForRow(at: indexPath) as? ProfileActivityCell,
                 let locationName = cell.activityTableLocation.text {
                 let geocoder = CLGeocoder()
                 geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                     guard let self = self,
                         let placemark = placemarks?.first,
                         let locationCoordinate = placemark.location?.coordinate else {
                             cell.accessoryView = nil
                             return
              }
              if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                   detailController.activityID = activity.activityID
                   self.selectedMarker?.map = nil
                   self.selectedMarker = nil
                   detailController.selectedLocationInfo = (name: locationName, coordinate: locationCoordinate)
                   //detailController.delegate = self
                   cell.accessoryView = nil
                   self.navigationController?.pushViewController(detailController, animated: false)
                     }
                 }
             }
             tableView.deselectRow(at: indexPath, animated: true)
         }
    }
}

//MARK: - Segments API
extension ProfileVC {
    func getActivityAPiCall(){
        let endPoint = APIConstants.Endpoints.userActivities
        var urlString = APIConstants.baseURL + endPoint
        urlString += "?limit=100"
        
        if let receiverID = receiverID {
                urlString += "&id=" + receiverID
            } else if let userID = UserDefaults.standard.string(forKey: "userID") {
                urlString += "&id=" + userID
            } else {
                showAlert(title: "Alert", message: "Both receiverID and userID are missing")
                return
            }
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey"){
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=117c57138897e041c1da019bb55d6e38d6eade11", forHTTPHeaderField: "Cookie")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Alert", message: "An error occurred: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                self.showAlert(title: "Alert", message: "No data received")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(UserActivityModel.self, from: data)
                self.activity = responseData.body.activities
                print(responseData.body)
                DispatchQueue.main.async {
                    self.profileActivityTableView.reloadData()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    func followerAPICall() {
        let endPoint = APIConstants.Endpoints.followers
        var urlString = APIConstants.baseURL + endPoint
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
        request.httpMethod = "GET"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
       
        request.addValue("ci_session=117c57138897e041c1da019bb55d6e38d6eade11", forHTTPHeaderField: "Cookie")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Alert", message: "An error occurred: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.showAlert(title: "Alert", message: "No data received")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(FollowerModel.self, from: data)
                self.followers = responseData.body.connections
                print(responseData.body)
                DispatchQueue.main.async {
                    self.profileFollowerTableView.reloadData()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    func followingAPICall() {
        let endPoint = APIConstants.Endpoints.following
        var urlString = APIConstants.baseURL + endPoint
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
        request.httpMethod = "GET"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=f78d9f7ae33419e3cf756d7252f41ceb1a369386", forHTTPHeaderField: "Cookie")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Alert", message: "An error occurred: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                self.showAlert(title: "Alert", message: "No data received")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(FollowingModel.self, from: data)
                self.followings = responseData.body.connections
                print(responseData.body)
                DispatchQueue.main.async {
                    self.profileFollowingTableView.reloadData()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
}
