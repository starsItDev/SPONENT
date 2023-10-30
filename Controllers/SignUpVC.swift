//
//  SignUpVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 07/09/2023.
//

import UIKit
import CoreLocation

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var actions: [UIAlertAction] = []
    var activeTextField: UITextField?
    var tapGestureRecognizer: UITapGestureRecognizer?
    let textFieldDelegateHelper = TextFieldDelegateHelper<SignUpVC>()
    let ages = ["Age 17", "Age 18", "Age 19", "Age 20", "Age 21", "Age 22", "Age 23", "Age 24", "Age 25", "Age 26", "Age 27", "Age 28", "Age 29", "Age 30", "Age 31", "Age 32", "Age 33", "Age 34", "Age 35", "Age 36", "Age 37", "Age 38", "Age 39", "Age 40", "Age 41", "Age 42", "Age 43", "Age 44", "Age 45", "Age 46", "Age 47", "Age 48", "Age 49", "Age 50", "Age 51", "Age 52", "Age 53", "Age 54", "Age 55"]
    let genders = ["Male", "Female"]
    var categories: [Category] = []
    var updateCategoryId: String?
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        emailTxtField.delegate = self
        passWordTxtField.delegate = self
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
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let userLocation = appDelegate.userLocation {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                  if let placemark = placemarks?.first {
                     if let locality = placemark.locality {
                        self.locationLabel.text = locality
                        self.locationLabel.textColor = .black
                    } else {
                        self.locationLabel.text = "\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)"
                    }
                }
            }
        }
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - API Calling
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
              let name = nameTxtField.text, !name.isEmpty,
              let email = emailTxtField.text, !email.isEmpty,
              let password = passWordTxtField.text, !password.isEmpty,
              let age = ageLabel.text, !age.isEmpty,
              let gender = genderLabel.text, !gender.isEmpty,
              let aboutMe = aboutMeTxtField.text, !aboutMe.isEmpty,
              let location = locationLabel.text, !location.isEmpty
        else {
            showAlert(title: "Alert", message: "Please fill in all required fields")
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

        let textFields = [
            "name": name,
            "email": email,
            "password": password,
            "age": age,
            "gender": gender,
            "aboutMe": aboutMe,
            "category_id": self.updateCategoryId ?? "",
            "location[latitude]": String(latitude),
            "location[longitude]": String(longitude),
            "location[location]": location
        ] as [String : Any]

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
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to fetch data from the server.")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        print("OKKKKK")
                        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: false)
                         }
                    } else {
                        self.showAlert(title: "Error", message: "Invalid Email or Password")
                    }
                }
            }
        }.resume()
    }
    //MARK: - Helper functions
    func styleViews() {
        ageView.applyBorder()
        genderView.applyBorder()
        nameView.applyBorder()
        emailView.applyBorder()
        passwdView.applyBorder()
        favCategoryView.applyBorder()
        aboutView.applyBorder()
        locationView.applyBorder()
    }
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    @objc func showAgeActionSheet() {
         actions.removeAll()
         for age in ages {
            let action = UIAlertAction(title: age, style: .default) { [weak self ] _ in
            self?.ageLabel.text = age
            self?.ageLabel.textColor = .black
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             imageView.image = selectedImage
        }
            picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
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
    
    //MARK: - Actions
    @IBAction func signUpForwardButton(_ sender: UIButton) {
        apiCall()
    }
    @IBAction func signUpBackButton(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
 }

