//
//  SignUpVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 07/09/2023.
//

import UIKit
import CoreLocation

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: - Variables
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwdView: UIView!
    @IBOutlet weak var favCategoryView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpIMageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var favCategoryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passWordTxtField: UITextField!
    @IBOutlet weak var aboutMeTxtField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var confirmPasswdView: UIView!
    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var confirmPasswdText: UITextField!
    @IBOutlet weak var confirmPasswdEye: UIButton!
    @IBOutlet weak var categoryTopConstraint: NSLayoutConstraint!
    var actions: [UIAlertAction] = []
    var activeTextField: UITextField?
    var tapGestureRecognizer: UITapGestureRecognizer?
    let textFieldDelegateHelper = TextFieldDelegateHelper<SignUpVC>()
    let ages = ["Age 17", "Age 18", "Age 19", "Age 20", "Age 21", "Age 22", "Age 23", "Age 24", "Age 25", "Age 26", "Age 27", "Age 28", "Age 29", "Age 30", "Age 31", "Age 32", "Age 33", "Age 34", "Age 35", "Age 36", "Age 37", "Age 38", "Age 39", "Age 40", "Age 41", "Age 42", "Age 43", "Age 44", "Age 45", "Age 46", "Age 47", "Age 48", "Age 49", "Age 50", "Age 51", "Age 52", "Age 53", "Age 54", "Age 55"]
    let genders = ["Male", "Female"]
    var categories: [Category] = []
    var updateCategoryId: String?
    var locationManager:CLLocationManager!
    var name: String?
    var email: String?
    var isSocialLogin: Bool?
    var socialID: String?
    var socialType: String?

    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSocialLogin ?? false {
            nameTxtField.text = self.name
            emailTxtField.text = self.email
            nameTxtField.isUserInteractionEnabled = false
            emailTxtField.isUserInteractionEnabled = false
            passwdView.isHidden = true
            confirmPasswdView.isHidden = true
            NSLayoutConstraint(item: favCategoryView!, attribute: .top, relatedBy: .equal, toItem: emailView, attribute: .bottom, multiplier: 1, constant: 12).isActive = true
        }
        styleViews()
        nameTxtField.delegate = self
        emailTxtField.delegate = self
        passWordTxtField.delegate = self
        confirmPasswdText.delegate = self
        aboutMeTxtField.delegate = self
        setupKeyboardDismiss()
        setupTapGesture(for: ageView, action: #selector(showAgeActionSheet))
        setupTapGesture(for: genderView, action: #selector(showGenderActionSheet))
        setupTapGesture(for: favCategoryView, action: #selector(showSportActionSheet))
        setupTapGesture(for: signUpIMageView, action: #selector(showImagePicker))
        apiCalltwo { [weak self] result in
               switch result {
               case .success(let categoriesModel):
                   self?.categories = categoriesModel.body.categories
               case .failure(let error):
                   print("API call error: \(error)")
               }
           }
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let userLocation = appDelegate.userLocation {
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                        if let placemark = placemarks?.first {
                            if let locationName = placemark.name {
                                self.locationLabel.text = locationName
                                self.locationLabel.textColor = .black
                            } else {
                                self.locationLabel.text = "Location Name Not Found"
                            }

                            if let country = placemark.country {
                                self.locationLabel.text! += ", \(country)"
                            }
                        }
                    }
                }
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - API Calling
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let userLocation = locations.first else {
//            print("Error: No user location found.")
//            return
//        }
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
//            if let error = error {
//                print("Error in reverseGeocode: \(error)")
//                return
//            }
//            if let placemark = placemarks?.first {
//                print(placemark)
//                var locationString = ""
//                if let name = placemark.name {
//                    locationString += "\(name), "
//                }
//                if let country = placemark.country {
//                    locationString += "\(country), "
//                }
//                if let subLocality = placemark.subLocality {
//                    locationString += "\(subLocality), "
//                }
//                if let subAdminArea = placemark.subAdministrativeArea {
//                    locationString += "\(subAdminArea)"
//                }
//                locationString = String(locationString.dropLast(2))
//                self.locationLabel.text = locationString
//                self.locationLabel.textColor = .black
//            }
//        }
//    }
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let userLocation :CLLocation = locations[0] as CLLocation
    //
    //        let geocoder = CLGeocoder()
    //        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
    //            if (error != nil){
    //                print("error in reverseGeocode")
    //            }
    //            let placemark = placemarks! as [CLPlacemark]
    //            if placemark.count>0{
    //                let placemark = placemarks![0]
    //                //print(placemark.region!)
    //               // print(placemark.subThoroughfare!)
    //               // print(placemark.thoroughfare!)
    //                print(placemark.name!)
    //
    //                self.locationLabel.text = "\(placemark.name!), \(placemark.locality!)"
    //                self.locationLabel.textColor = .black
    //            }
    //        }
    //    }
    func apiCalltwo(completion: @escaping (Result<CategoriesModel, Error>) -> Void) {
        let endpoint = APIConstants.Endpoints.categories
        let urlString = APIConstants.baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.addValue("ci_session=ecb2cacef693dd7c6e5068c41a6d248b91904385", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 1, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let categoriesModel = try decoder.decode(CategoriesModel.self, from: data)
                completion(.success(categoriesModel))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    func apiCall() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let userLocation = appDelegate.userLocation,
              let location = locationLabel.text, !location.isEmpty
        else {
            showAlert(title: "Alert", message: "Please enable location for Signup")
            return
        }

        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude

        let endpoint = APIConstants.Endpoints.signup
        let urlString = APIConstants.baseURL + endpoint

        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        var textFields = [
            "name": nameTxtField.text ?? "",
            "email": emailTxtField.text ?? "",
            "password": passWordTxtField.text ?? "",
            "age": ageLabel.text ?? "",
            "gender": genderLabel.text ?? "",
            "aboutMe": aboutMeTxtField.text ?? "",
            "category_id": self.updateCategoryId ?? "",
            "location[latitude]": String(latitude),
            "location[longitude]": String(longitude),
            "location[location]": location
        ] as [String : Any]

        if isSocialLogin ?? false {
            let socialLoginPassword = "social_login_password"
            textFields.updateValue(self.socialID ?? "", forKey: "socialId")
            textFields.updateValue(self.socialType ?? "", forKey: "socialType")
            textFields.updateValue(socialLoginPassword , forKey: "password")
            confirmPasswdText.text = "social_login_password"
            passWordTxtField.text = "social_login_password"
        }
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        if let image = imageView.image, let imageData = image.jpegData(compressionQuality: 0.7) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

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
    @IBAction func signUpForwardButton(_ sender: UIButton) {
        ValidationCode()
    }
    @IBAction func signUpBackButton(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    @IBAction func passwdEyeBtn(_ sender: UIButton) {
        if passWordTxtField.isSecureTextEntry {
            passWordTxtField.isSecureTextEntry = false
            let eyeImage = UIImage(systemName: "eye")
            passwordEye.setImage(eyeImage, for: .normal)
            passwordEye.tintColor = .darkGray
        } else {
            passWordTxtField.isSecureTextEntry = true
            let eyeSlashImage = UIImage(systemName: "eye.slash")
            passwordEye.setImage(eyeSlashImage, for: .normal)
            passwordEye.tintColor = .lightGray
        }
    }
    @IBAction func confirmPasswdEyeBtn(_ sender: UIButton) {
        if confirmPasswdText.isSecureTextEntry {
            confirmPasswdText.isSecureTextEntry = false
            let eyeImage = UIImage(systemName: "eye")
            confirmPasswdEye.setImage(eyeImage, for: .normal)
            confirmPasswdEye.tintColor = .darkGray
        } else {
            confirmPasswdText.isSecureTextEntry = true
            let eyeSlashImage = UIImage(systemName: "eye.slash")
            confirmPasswdEye.setImage(eyeSlashImage, for: .normal)
            confirmPasswdEye.tintColor = .lightGray
        }
    }
    
    //MARK: - Helper functions
    @objc func showAgeActionSheet() {
         actions.removeAll()
         for age in ages {
            let action = UIAlertAction(title: age, style: .default) { [weak self ] _ in
            self?.ageLabel.text = age
            self?.ageLabel.textColor = .black
            self?.ageView.layer.borderColor = UIColor.lightGray.cgColor
            }
         actions.append(action)
      }
         presentActionSheet(title: "Select age", message: nil, actions: actions)
   }
    @objc func showGenderActionSheet() {
         actions.removeAll()
         for gender in genders {
            let actionTwo = UIAlertAction(title: gender, style: .default) { [weak self] _ in
            self?.genderLabel.text = gender
            self?.genderLabel.textColor = .black
            self?.genderView.layer.borderColor = UIColor.lightGray.cgColor
         }
         actions.append(actionTwo)
      }
         presentActionSheet(title: "Select Gender", message: nil, actions: actions)
   }
    @objc func showSportActionSheet() {
         actions.removeAll()
        for category in categories {
            let actionOne = UIAlertAction(title: category.title, style: .default) { [weak self] _ in
                self?.favCategoryLabel.text = category.title
                self?.updateCategoryId = category.categoryID
                self?.favCategoryLabel.textColor = .black
                self?.favCategoryView.layer.borderColor = UIColor.lightGray.cgColor
         }
         actions.append(actionOne)
      }
        presentActionSheet(title: "Select Category", message: nil, actions: actions)
    }
    @objc func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            if let activeField = activeTextField {
            let rect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             imageView.image = selectedImage
        }
            picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
    }
    func ValidationCode() {
        guard  let email = emailTxtField.text, let password = passWordTxtField.text, let confirm = confirmPasswdText.text else {
            return
        }
        if isSocialLogin == true {
           if ageLabel.text == "Age" || genderLabel.text == "Gender" || nameTxtField.text == "" || emailTxtField.text == "" || favCategoryLabel.text == "Select Your Favorite Category" || aboutMeTxtField.text == "" {
                if ageLabel.text == "Age" {
                ageView.layer.borderColor = UIColor.red.cgColor
                }
                if genderLabel.text == "Gender" {
                genderView.layer.borderColor = UIColor.red.cgColor
                }
                if nameTxtField.text == "" {
                   nameView.layer.borderColor = UIColor.red.cgColor
                }
                if emailTxtField.text == "" {
                emailView.layer.borderColor = UIColor.red.cgColor
                }
                if favCategoryLabel.text == "Select Your Favourite Category" {
                favCategoryView.layer.borderColor = UIColor.red.cgColor
                }
                if aboutMeTxtField.text == "" {
                aboutView.layer.borderColor = UIColor.red.cgColor
            }
            showAlert(title: "Alert", message: "Please fill in all required fields")
        } else {
            emailView.layer.borderColor = UIColor.lightGray.cgColor
            
            if !email.validateEmailId() {
                emailView.layer.borderColor = UIColor.red.cgColor
                showAlert(title: "Alert", message: "Please enter a correct email")
                return
            } else {
                emailView.layer.borderColor = UIColor.lightGray.cgColor
            }
            apiCall()
         }
    } else {
        if ageLabel.text == "Age" || genderLabel.text == "Gender" || nameTxtField.text == "" || emailTxtField.text == "" || passWordTxtField.text == "" || confirmPasswdText.text == ""
            || favCategoryLabel.text == "Select Your Favorite Category" || aboutMeTxtField.text == "" {
                if ageLabel.text == "Age" {
                    ageView.layer.borderColor = UIColor.red.cgColor
                }
                if genderLabel.text == "Gender" {
                    genderView.layer.borderColor = UIColor.red.cgColor
                }
                if nameTxtField.text == "" {
                    nameView.layer.borderColor = UIColor.red.cgColor
                }
                if emailTxtField.text == "" {
                    emailView.layer.borderColor = UIColor.red.cgColor
                }
                if passWordTxtField.text == "" {
                    passwdView.layer.borderColor = UIColor.red.cgColor
                }
                if confirmPasswdText.text == "" {
                    confirmPasswdView.layer.borderColor = UIColor.red.cgColor
                }
                if favCategoryLabel.text == "Select Your Favourite Category" {
                    favCategoryView.layer.borderColor = UIColor.red.cgColor
                }
                if aboutMeTxtField.text == "" {
                    aboutView.layer.borderColor = UIColor.red.cgColor
                }
            showAlert(title: "Alert", message: "Please fill in all required fields")
            } else {
                emailView.layer.borderColor = UIColor.lightGray.cgColor
                passwdView.layer.borderColor = UIColor.lightGray.cgColor
                confirmPasswdView.layer.borderColor = UIColor.lightGray.cgColor
                
                if !email.validateEmailId() {
                    emailView.layer.borderColor = UIColor.red.cgColor
                    showAlert(title: "Alert", message: "Please enter a correct email")
                    return
                } else {
                    emailView.layer.borderColor = UIColor.lightGray.cgColor
                }
                if password.count < 6 {
                    passwdView.layer.borderColor = UIColor.red.cgColor
                    showAlert(title: "Alert", message: "Password should be at least 6 characters")
                    return
                } else {
                    passwdView.layer.borderColor = UIColor.lightGray.cgColor
                }
                if confirm.count < 6 {
                    confirmPasswdView.layer.borderColor = UIColor.red.cgColor
                    showAlert(title: "Alert", message: "Confirm password should be at least 6 characters")
                    return
                } else {
                    confirmPasswdView.layer.borderColor = UIColor.lightGray.cgColor
                }
                if password != confirm {
                    passwdView.layer.borderColor = UIColor.red.cgColor
                    confirmPasswdView.layer.borderColor = UIColor.red.cgColor
                    showAlert(title: "Alert", message: "Both passwords should be the same")
                    return
                }
            apiCall()
          }
      }
   }
    func styleViews() {
        ageView.applyBorder()
        genderView.applyBorder()
        nameView.applyBorder()
        emailView.applyBorder()
        passwdView.applyBorder()
        confirmPasswdView.applyBorder()
        favCategoryView.applyBorder()
        aboutView.applyBorder()
        locationView.applyBorder()
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
}

//MARK: - Extension TextField
extension SignUpVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
            if textField == nameTxtField {
                nameView.layer.borderColor = UIColor.lightGray.cgColor
            } else if textField == emailTxtField {
                emailView.layer.borderColor = UIColor.lightGray.cgColor
            } else if textField == passWordTxtField {
                passwdView.layer.borderColor = UIColor.lightGray.cgColor
            } else if textField == confirmPasswdText {
                confirmPasswdView.layer.borderColor = UIColor.lightGray.cgColor
            } else if textField == aboutMeTxtField {
               aboutView.layer.borderColor = UIColor.lightGray.cgColor
            }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
 }

