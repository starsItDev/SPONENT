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
    var actions: [UIAlertAction] = []
    var tapGestureRecognizer: UITapGestureRecognizer?
    let textFieldDelegateHelper = TextFieldDelegateHelper<SignUpVC>()
    let ages = ["Age 17", "Age 18", "Age 19", "Age 20", "Age 21", "Age 22", "Age 23", "Age 24", "Age 25", "Age 26", "Age 27", "Age 28", "Age 29", "Age 30", "Age 31", "Age 32", "Age 33", "Age 34", "Age 35", "Age 36", "Age 37", "Age 38", "Age 39", "Age 40", "Age 41", "Age 42", "Age 43", "Age 44", "Age 45", "Age 46", "Age 47", "Age 48", "Age 49", "Age 50", "Age 51", "Age 52", "Age 53", "Age 54", "Age 55"]
    let genders = ["Any", "Male", "Female"]
    let categories = ["Cricket", "Baseball", "Golf", "Hockey", "Martial Arts"]
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        setupKeyboardDismiss()
        setupTapGesture(for: ageView, action: #selector(showAgeActionSheet))
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
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    @objc func showAgeActionSheet() {
         actions.removeAll()
         for age in ages {
            let action = UIAlertAction(title: age, style: .default) { [weak self ] _ in
            self?.ageLabel.text = age
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

