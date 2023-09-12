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
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var favCategoryLabel: UILabel!
    @IBOutlet weak var ageTableView: UITableView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpIMageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    var actions: [UIAlertAction] = []
    var tapGestureRecognizer: UITapGestureRecognizer?
    let textFieldDelegateHelper = TextFieldDelegateHelper<SignUpVC>()
    let genders = ["Any", "Male", "Female"]
    let categories = ["Cricket", "Baseball", "Golf", "Hockey", "Martial Arts"]
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        ageTableView.isHidden = true
        styleViews()
        setupKeyboardDismiss()
        setupTapGesture(for: ageView, action: #selector(showAgeTableView))
        setupTapGesture(for: genderView, action: #selector(showGenderActionSheet))
        setupTapGesture(for: favCategoryView, action: #selector(showSportActionSheet))
        setupTapGesture(for: signUpIMageView, action: #selector(showImagePicker))
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let userLocation = appDelegate.userLocation {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                    if let placemark = placemarks?.first {
                        self.locationLabel.text = placemark.locality
                }
            }
        }
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
    @objc func showAgeTableView() {
        if ageTableView.isHidden == true {
            ageTableView.isHidden = false
        } else {
            ageTableView.isHidden = true
        }
    }
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    @objc func showGenderActionSheet() {
         actions.removeAll()
         for gender in genders {
            let actionTwo = UIAlertAction(title: gender, style: .default) { [weak self] _ in
            self?.genderLabel.text = gender
        }
         actions.append(actionTwo)
     }
         presentActionSheet(title: "Select Gender", message: nil, actions: actions)
  }
    @objc func showSportActionSheet() {
         actions.removeAll()
        for category in categories {
            let actionOne = UIAlertAction(title: category, style: .default) { [weak self] _ in
            self?.favCategoryLabel.text = category
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
    
    //MARK: - Actions
    @IBAction func signUpForwardButton(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
}

extension SignUpVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 83
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SignUpAgeTableViewCell
        if indexPath.row == 0 {
            cell.cellAgeLabel?.text = "Select age"
        } else {
            let age = indexPath.row + 17
            cell.cellAgeLabel?.text = "\(age)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let selectedAge = indexPath.row + 17
            ageLabel.text = "\(selectedAge)"
        }
        ageTableView.isHidden = true
    }
}

