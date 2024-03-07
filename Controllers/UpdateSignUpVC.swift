//
//  UpdateSignUpVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 18/09/2023.
//

import UIKit
import CoreLocation

struct UserProfileData {
    var profileImage: UIImage?
    var name: String?
    var age: String?
    var gender: String?
    var category: String?
    var aboutMe: String?
    var categoryID: Int?
}

 class UpdateSignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Variables
    @IBOutlet weak var signUpImageView: UIView!
    @IBOutlet weak var updateImage: UIImageView!
    @IBOutlet weak var updateAgeView: UIView!
    @IBOutlet weak var updateGenderView: UIView!
    @IBOutlet weak var updateNameView: UIView!
    @IBOutlet weak var updateCategoryView: UIView!
    @IBOutlet weak var updateAboutView: UIView!
    @IBOutlet weak var updateLocactionView: UIView!
    @IBOutlet weak var updateAgeLabel: UILabel!
    @IBOutlet weak var updateGenderLabel: UILabel!
    @IBOutlet weak var updateCategoryLabel: UILabel!
    @IBOutlet weak var updateLocationLabel: UILabel!
    @IBOutlet weak var updateNameField: UITextField!
    @IBOutlet weak var updateAboutField: UITextField!
    @IBOutlet weak var updateScrollView: UIScrollView!
    var actions: [UIAlertAction] = []
    var activeTextField: UITextField?
    var tapGestureRecognizer: UITapGestureRecognizer?
    let textFieldDelegateHelper = TextFieldDelegateHelper<UpdateSignUpVC>()
    let Updateages = ["Age 17", "Age 18", "Age 19", "Age 20", "Age 21", "Age 22", "Age 23", "Age 24", "Age 25", "Age 26", "Age 27", "Age 28", "Age 29", "Age 30", "Age 31", "Age 32", "Age 33", "Age 34", "Age 35", "Age 36", "Age 37", "Age 38", "Age 39", "Age 40", "Age 41", "Age 42", "Age 43", "Age 44", "Age 45", "Age 46", "Age 47", "Age 48", "Age 49", "Age 50", "Age 51", "Age 52", "Age 53", "Age 54", "Age 55"]
    let Updategenders = ["Male", "Female"]
    var Updatecategories: [Category] = []
    var userProfileData: UserProfileData?
    var categoryID: Int?
       
    //MARK: - Override Fuction
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        updateNameField.delegate = self
        updateAboutField.delegate = self
        setupKeyboardDismiss()
        setupTapGesture(for: updateAgeView, action: #selector(showAgeActionSheet))
        setupTapGesture(for: updateGenderView, action: #selector(showGenderActionSheet))
        setupTapGesture(for: updateCategoryView, action: #selector(showSportActionSheet))
        setupTapGesture(for: signUpImageView, action: #selector(showImagePicker))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        categoriesApiCall { [weak self] result in
               switch result {
               case .success(let categoriesModel):
                   self?.Updatecategories = categoriesModel.body.categories
                   print(self?.Updatecategories ?? "")
               case .failure(let error):
                   print("API call error: \(error)")
               }
           }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let userLocation = appDelegate.userLocation {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                  if let placemark = placemarks?.first {
                     if let locality = placemark.name {
                        self.updateLocationLabel.text = locality
                         if self.traitCollection.userInterfaceStyle == .dark {
                             self.updateLocationLabel.textColor = .white
                         } else {
                             self.updateLocationLabel.textColor = .black
                         }
                     } else {
                        self.updateLocationLabel.text = "\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)"
                    }
                }
            }
        }
        if let userProfileData = userProfileData {
            updateImage.image = userProfileData.profileImage
            updateNameField.text = userProfileData.name
            updateAgeLabel.text = userProfileData.age
            updateGenderLabel.text = userProfileData.gender
            updateCategoryLabel.text = userProfileData.category
            self.categoryID = userProfileData.categoryID
            updateAboutField.text = userProfileData.aboutMe
            if self.traitCollection.userInterfaceStyle == .dark {
                updateAgeLabel.textColor = .white
                updateGenderLabel.textColor = .white
                updateNameField.textColor = .white
                updateAboutField.textColor = .white
                updateCategoryLabel.textColor = .white
            } else {
                updateAgeLabel.textColor = .black
                updateGenderLabel.textColor = .black
                updateNameField.textColor = .black
                updateAboutField.textColor = .black
                updateCategoryLabel.textColor = .black
            }
        }
    }
       
    //MARK: - API Calling
    func apiCall(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let userlocation = appDelegate.userLocation,
              let location = updateLocationLabel.text, !location.isEmpty
        else {
            showToast(message: "Please fill in all required fields")
            return
        }
        let latitude = userlocation.coordinate.latitude
        let longitude = userlocation.coordinate.longitude

        let endpoint = APIConstants.Endpoints.userUpdateProfile
        let urlString = APIConstants.baseURL + endpoint

        guard let url = URL(string: urlString) else {
            showToast(message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
           request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let apikey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apikey, forHTTPHeaderField: "authorizuser")
        }

        var body = Data()
        let textFields = [
            "name": updateNameField.text ?? "",
            "age": updateAgeLabel.text ?? "",
            "gender": updateGenderLabel.text ?? "",
            "aboutMe": updateAboutField.text ?? "",
            "category_id": self.categoryID ?? "",
            "location[latitude]": String(latitude),
            "location[longitude]": String(longitude),
            "location[location]": location
        ] as [String : Any]
        for (key, value) in textFields {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        if let image = updateImage.image, let imageData = image.jpegData(compressionQuality: 0.7) {
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
                    self.showToast(message: "Failed to fetch data from the server")
                }
                return
            }
        if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        print("Update Successful")
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        self.showToast(message: "Failed to update profile")
                    }
                }
            }
        }.resume()
    }
    func categoriesApiCall(completion: @escaping (Result<CategoriesModel, Error>) -> Void) {
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
     
    //MARK: - Helper functions
    func styleViews() {
        updateAgeView.applyBorder()
        updateGenderView.applyBorder()
        updateNameView.applyBorder()
        updateCategoryView.applyBorder()
        updateAboutView.applyBorder()
        updateLocactionView.applyBorder()
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                updateImage.image = selectedImage
            }
            picker.dismiss(animated: true, completion: nil)
     }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
    }
    func ValidationCode() {
        if updateNameField.text == "" {
            updateNameView.layer.borderColor = UIColor.red.cgColor
            showToast(message: "Please write your name")
        }
        else if updateAboutField.text == "" {
            updateAboutView.layer.borderColor = UIColor.red.cgColor
            showToast(message: "Please write something about yourself")
        }
        else {
            apiCall()
        }
    }
    @objc func showAgeActionSheet() {
        view.endEditing(true)
        actions.removeAll()
        for age in Updateages {
            let action = UIAlertAction(title: age, style: .default) { [weak self ] _ in
            self?.updateAgeLabel.text = age
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.updateAgeLabel.textColor = .white
                } else {
                    self?.updateAgeLabel.textColor = .black
                }
            }
        actions.append(action)
     }
        presentActionSheet(title: "Select age", message: nil, actions: actions)
  }
    @objc func showGenderActionSheet() {
        view.endEditing(true)
        actions.removeAll()
        for gender in Updategenders {
            let actionTwo = UIAlertAction(title: gender, style: .default) { [weak self] _ in
            self?.updateGenderLabel.text = gender
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.updateGenderLabel.textColor = .white
                } else {
                    self?.updateGenderLabel.textColor = .black
                }
            }
            actions.append(actionTwo)
        }
            presentActionSheet(title: "Select Gender", message: nil, actions: actions)
    }
    @objc func showSportActionSheet() {
        view.endEditing(true)
        actions.removeAll()
        for category in Updatecategories {
            let actionOne = UIAlertAction(title: category.title, style: .default) { [weak self] _ in
                self?.updateCategoryLabel.text = category.title
                self?.categoryID = Int(category.categoryID)
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.updateCategoryLabel.textColor = .white
                } else {
                    self?.updateCategoryLabel.textColor = .black
                }
            }
            actions.append(actionOne)
        }
            presentActionSheet(title: "Select Category", message: nil, actions: actions)
    }
    @objc func showImagePicker() {
        view.endEditing(true)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            updateScrollView.contentInset = contentInsets
            updateScrollView.scrollIndicatorInsets = contentInsets
            if let activeField = activeTextField {
            let rect = activeField.convert(activeField.bounds, to: updateScrollView)
            updateScrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        updateScrollView.contentInset = contentInsets
        updateScrollView.scrollIndicatorInsets = contentInsets
    }
     
     //MARK: - Actions
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func forwardButton(_ sender: UIButton) {
        ValidationCode()
    }
}

 //MARK: - Extension TextField
 extension UpdateSignUpVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
            if textField == updateNameField {
                updateNameView.layer.borderColor = UIColor.lightGray.cgColor
            } else if textField == updateAboutField {
                updateAboutView.layer.borderColor = UIColor.lightGray.cgColor
            }
    }
   func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
   }
}
