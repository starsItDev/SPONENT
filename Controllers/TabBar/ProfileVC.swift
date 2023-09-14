//
//  ProfileVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/08/2023.
//

import UIKit

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
    let textFieldDelegateHelper = TextFieldDelegateHelper<ProfileVC>()
    
    @IBOutlet weak var imgProfileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var sportNameLabel: UILabel!
    @IBOutlet weak var loctionLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetUp()
        apiCall()
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
        request.addValue("2d3a86715b724bdd7502e86cdda2eef8", forHTTPHeaderField: "authorizuser")
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
                    
                    if let avatarURLString = body["avatar"] as? String,
                       let avatarURL = URL(string: avatarURLString) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: avatarURL),
                               let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.imgProfileView.image = image
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
            // Handle the JSON parsing error as needed
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
    }
    @IBAction func editProfileButton(_ sender: UIButton) {
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC {
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
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    @IBAction func updateCancelButton(_ sender: UIButton) {
        if changePasswordView.isHidden == false {
            changePasswordView.isHidden = true
        }
    }
    @IBAction func updateOkButton(_ sender: UIButton) {
    }
    //MARK: - Helper Functions
    func uiSetUp(){
        profileSegmentView.isHidden = false
        profileActivityView.isHidden = true
        profileFollowerView.isHidden = true
        profileFollowingView.isHidden = true
        settingStackView.isHidden = true
        changePasswordView.isHidden = true
        oldPasswordField.layer.cornerRadius = 5
        oldPasswordField.layer.borderWidth = 1.0
        oldPasswordField.layer.borderColor = UIColor.black.cgColor
        newPasswordField.layer.cornerRadius = 5
        newPasswordField.layer.borderWidth = 1.0
        newPasswordField.layer.borderColor = UIColor.black.cgColor
        setupKeyboardDismiss()
        self.navigationController?.navigationBar.isHidden = true
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
}
