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

protocol ProfileDelegate: AnyObject {
    func didTapUserProfileSettingButton()
}
class ProfileVC: UIViewController, UITextFieldDelegate, ProfileDelegate, DetailViewControllerDelegate {

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
    @IBOutlet weak var profileFollowingTableView: UITableView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportNameLabel: UILabel!
    @IBOutlet weak var loctionLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var myProfileLabel: UILabel!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ProfileVC>()
    var delegate: ProfileDelegate?
    let updateSignUpVC = UpdateSignUpVC()
    var isProfileBackButtonHidden = true
    var isFollowButtonHidden = true
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
        tabsApiCall()
    }
    
    //MARK: - API CAllING
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
                    //self.blockButton.setTitle("Block", for: .normal)
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
            settingStackView.isHidden = true
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
        profileSegmentController.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
        if let labelText = labelText {
            myProfileLabel.text = labelText
        }
        dismissViewTap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
            if let tap = dismissViewTap {
                view.addGestureRecognizer(tap)
            }
        setupKeyboardDismiss()
        self.navigationController?.navigationBar.isHidden = true
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    func updateFollowButtonTitle() {
        if let userID = receiverID {
            let followStatus = UserDefaults.standard.bool(forKey: "FollowStatus_\(userID)")
            if followStatus == true {
                followButton.setTitle("Unfollow", for: .normal)
            } else {
                followButton.setTitle("Follow", for: .normal)
            }
        }
    }
    func updateBlockButtonTitle() {
        if let userID = receiverID {
            let blockStatus = UserDefaults.standard.bool(forKey: "BlockStatus_\(userID)")
            if blockStatus == true {
                blockButton.setTitle("Unblock", for: .normal)
            } else {
                blockButton.setTitle("Block", for: .normal)
            }
        }
    }
    func didTapUserProfileSettingButton() {
        if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
            if profileVC.userSettingStackView.isHidden {
                 profileVC.userSettingStackView.isHidden = false
                 profileVC.settingStackView.isHidden = true
            } else {
                profileVC.userSettingStackView.isHidden = true
                profileVC.settingStackView.isHidden = true
            }
        }
    }
    func didSelectLocation(_ locationName: String) {
        let geocoder = CLGeocoder()
           geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
               if let placemark = placemarks?.first, let locationCoordinate = placemark.location?.coordinate {
                   self?.selectedLocationLatitude = locationCoordinate.latitude
                   self?.selectedLocationLongitude = locationCoordinate.longitude
            }
        }
    }
    @objc private func dismissView() {
        guard let tap = dismissViewTap else {
           return
        }
//      guard settingStackView.isHidden == false else {
//         return
//      }
        settingStackView.isHidden = true
        view.removeGestureRecognizer(tap)
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
              vc.delegate = self
              vc.isProfileBackButtonHidden = false
              vc.isFollowButtonHidden = false
              vc.receiverID = follower.userID
              let selectedText = "Profile"
              vc.labelText = selectedText
              self.navigationController?.pushViewController(vc, animated: true)
          }
        } else if tableView == profileFollowingTableView {
            let following = followings[indexPath.row]
            selectedReceiverID = following.userID
             if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                 vc.delegate = self
                 vc.isProfileBackButtonHidden = false
                 vc.isFollowButtonHidden = false
                 vc.receiverID = following.userID
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
                   detailController.delegate = self
                   cell.accessoryView = nil
                   let camera = GMSCameraPosition.camera(withLatitude:    locationCoordinate.latitude, longitude:                                          locationCoordinate.longitude, zoom: 15)
                   detailController.detailMapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
                  self.navigationController?.pushViewController(detailController, animated: false)
                     }
                 }
             }
             tableView.deselectRow(at: indexPath, animated: true)
         }
    }
}

//MARK: - Extension ProfileVC
extension ProfileVC {
    func getActivityAPiCall(){
        let endPoint = APIConstants.Endpoints.getActivities
        let urlString = APIConstants.baseURL + endPoint
//        if let storedUserID = UserDefaults.standard.object(forKey: "userID") as? String {
//            urlString += "?id=" + storedUserID
//        }
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
}
