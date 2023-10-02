//
//  HomeVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/08/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces

class HomeVC: UIViewController, GMSMapViewDelegate, DetailViewControllerDelegate {
    
    //MARK: - Variable
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var homeSegmentController: UISegmentedControl!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var homeSportBtn: UIButton!
    @IBOutlet weak var homeRangeBtn: UIButton!
    @IBOutlet weak var homeMapView: GMSMapView!
    @IBOutlet weak var addDetails: UIView!
    @IBOutlet weak var sportTypeView: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var participantView: UIView!
    @IBOutlet weak var skillView: UIView!
    @IBOutlet weak var sportTypeLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    @IBOutlet weak var addDetailsScroll: UIScrollView!
    @IBOutlet weak var addDetailsDoneButton: UIButton!
    @IBOutlet weak var addDetailsActivity: UITextField!
    @IBOutlet weak var addDetailsTextView: UITextView!
    @IBOutlet weak var addDetailsLocation: UIView!
    @IBOutlet weak var addDetailsLocLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    //var locationManager = CLLocationManager()
    var selectedCoordinate: CLLocationCoordinate2D?
    var actions: [UIAlertAction] = []
    var selectedLocation: String?
    var selectedRegion: GMSVisibleRegion?
    var placess: [GMSMarker] = []
    private var loadingView: UIView?
    var selectedMarker: GMSMarker?
    var selectedLocationLatitude: Double?
    var selectedLocationLongitude: Double?
    let textFieldDelegateHelper = TextFieldDelegateHelper<HomeVC>()
    var sports: [Category] = []
    var ages: [Agetype] = []
    let randomGenders = ["Any", "Male", "Female"]
    let randomParticipants = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13",
                     "14", "More than 15", "Team"]
    let randomSkills = ["Any", "Expert", "Perfect", "Middle", "Average"]
    let places = [
        place(title: "JT", coordinate: CLLocationCoordinate2D(latitude: 31.4697, longitude: 74.2728)),
        place(title: "MT", coordinate: CLLocationCoordinate2D(latitude: 31.4805, longitude: 74.3239))]
    let locations = ["Gulberg 2 Lahore", "Model Town Lahore", "Punjab University Main Ground"]
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        apiCall { [weak self] result in
               switch result {
               case .success(let categoriesModel):
                   self?.sports = categoriesModel.body.categories
                   self?.ages = categoriesModel.body.agetypes
               case .failure(let error):
                   print("API call error: \(error)")
               }
           }
        homeView.isHidden = false
        homeMapView.isHidden = true
        addDetails.isHidden = true
        setupKeyboardDismiss()
        styleViews()
        addAnnotations()
        addDetailsTextView.textColor = UIColor.lightGray
        //homeSportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        homeMapView.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        setupTapGesture(for: sportTypeView, action: #selector(showSportActionSheet))
        setupTapGesture(for: genderView, action: #selector(showGenderActionSheet))
        setupTapGesture(for: ageView, action: #selector(showAgeActionSheet))
        setupTapGesture(for: participantView, action:
        #selector(showParticipantActionSheet))
        setupTapGesture(for: skillView, action: #selector(showSkillActionSheet))
  }
    //MARK: - API Calling
    func apiCall(completion: @escaping (Result<CategoriesModel, Error>) -> Void) {
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
    func CreateActivityAPICall(){
        
      guard let categoryID = sportTypeLabel.text, !categoryID.isEmpty,
            let selectedDateAndTime = datePicker?.date,
            let activity = addDetailsActivity.text, !activity.isEmpty,
            let description = addDetailsTextView.text, !description.isEmpty,
            let gender = genderLabel.text, !gender.isEmpty,
            let startAge = ageLabel.text, !startAge.isEmpty,
            let endAge = ageLabel.text, !endAge.isEmpty,
            let participantNumber = participantLabel.text, !participantNumber.isEmpty,
            let skill = skillLabel.text, !skill.isEmpty,
            let location = addDetailsLocLabel.text, !location.isEmpty,
            let latitude = selectedLocationLatitude,
            let longitude = selectedLocationLongitude
        else {
            showAlert(title: "Alert", message: "Please fill in all required fields")
            return
        }
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: selectedDateAndTime)
            dateFormatter.dateFormat = "HH:mm:ss"
            let time = dateFormatter.string(from: selectedDateAndTime)
        
            print("Date: \(date)")
            print("Time: \(time)")
        
        var ageLabelText = ""
        if startAge == "Any" && endAge == "Teen Age" {
            ageLabelText = "Any Teen Age"
        } else {
            ageLabelText = "\(startAge) - \(endAge)"
        }

        let endpoint = APIConstants.Endpoints.createActivity
        let urlString = APIConstants.baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        let textFields = [
                "categoryId": categoryID,
                "date": date,
                "time": time,
                "activity": activity,
                "description": description,
                "number": participantNumber,
                "startAge": startAge,
                "endAge": endAge,
                "skill": skill,
                "gender": gender,
                "location[latitude]": String(latitude),
                "location[longitude]": String(longitude),
                "location[location]": location
            ]
        
        for (key, value) in textFields {
            if let keyData = "--\(boundary)\r\n".data(using: .utf8),
               let dispositionData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8),
               let valueData = "\(value)\r\n".data(using: .utf8) {
                body.append(keyData)
                body.append(dispositionData)
                body.append(valueData)
            }
        }
        if let ageLabelTextData = "--\(boundary)\r\nContent-Disposition: form-data; name=\"ageLabelText\"\r\n\r\n\(ageLabelText)\r\n".data(using: .utf8) {
            body.append(ageLabelTextData)
        }
        if let boundaryData = "--\(boundary)--\r\n".data(using: .utf8) {
            body.append(boundaryData)
        }
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
                        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                            //vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: false)
                         }
                    } else {
                        self.showAlert(title: "Error", message: "Failed")
                    }
                }
            }
        }.resume()
        
    }
    
    //MARK: - HelperFuntions
    @objc func showSportActionSheet() {
        actions.removeAll()
        for sport in sports {
            let actionOne = UIAlertAction(title: sport.title, style: .default) { [weak self] _ in
                self?.sportTypeLabel.text = sport.title
            }
            actions.append(actionOne)
        }
        presentActionSheet(title: "Select Sport Type", message: nil, actions: actions)
    }

    @objc func showGenderActionSheet() {
         actions.removeAll()
         for gender in randomGenders {
             let actionTwo = UIAlertAction(title: gender, style: .default) { [weak self] _ in
            self?.genderLabel.text = gender
        }
         actions.append(actionTwo)
     }
         presentActionSheet(title: "Select Gender", message: nil, actions: actions)
  }
    @objc func showAgeActionSheet() {
        actions.removeAll()
        for ageType in ages {
            let action = UIAlertAction(title: ageType.title, style: .default) { [weak self ] _ in
                self?.ageLabel.text = ageType.title
            }
            actions.append(action)
        }
        presentActionSheet(title: "Select age", message: nil, actions: actions)
    }

    @objc func showParticipantActionSheet() {
         actions.removeAll()
         for player in randomParticipants {
            let action = UIAlertAction(title: player, style: .default) { [weak self] _ in
            self?.participantLabel.text = player
       }
         actions.append(action)
     }
         presentActionSheet(title: "Select player", message: nil, actions: actions)
  }
    @objc func showSkillActionSheet() {
         actions.removeAll()
         for skill in randomSkills {
            let action = UIAlertAction(title: skill, style: .default) { [weak self] _ in
           self?.skillLabel.text = skill
       }
         actions.append(action)
     }
         presentActionSheet(title: "Select skill", message: nil, actions: actions)
  }
     func styleViews() {
         sportTypeView.applyBorder()
        // datePickerView.applyBorder()
         genderView.applyBorder()
         ageView.applyBorder()
         participantView.applyBorder()
         skillView.applyBorder()
         addDetailsLocation.applyBorder()
         addDetailsActivity.applyBorder()
         addDetailsTextView.applyBorder()
    }
     func addAnnotations() {
         for place in places {
                   let marker = GMSMarker()
                   marker.title = place.title
                   marker.position = place.coordinate!
                   marker.map = homeMapView
       }
   }
     func createLoadingView() {
        loadingView = UIView(frame: UIScreen.main.bounds)
        loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView!.center
        loadingView?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    func didSelectLocation(_ locationName: String) {
         addDetailsLocLabel.text = locationName
         selectedLocation = locationName
         homeSegmentController.selectedSegmentIndex = 2
         let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                if let placemark = placemarks?.first, let locationCoordinate = placemark.location?.coordinate {
                    self?.selectedLocationLatitude = locationCoordinate.latitude
                    self?.selectedLocationLongitude = locationCoordinate.longitude
                }
            }
         dismiss(animated: true, completion: nil)
    }
    func showLoadingView() {
        if loadingView == nil {
            createLoadingView()
        }
        loadingView?.isHidden = false
        view.addSubview(loadingView!)
    }
    func hideLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    
    
    //MARK: - Actions
    @IBAction func homeSegmentControl(_ sender: UISegmentedControl) {
      switch homeSegmentController.selectedSegmentIndex {
       case 0:
             homeView.isHidden = false
             homeMapView.isHidden = true
             addDetails.isHidden = true
       case 1:
             homeView.isHidden = true
             homeMapView.isHidden = false
             addDetails.isHidden = true
       case 2:
             homeView.isHidden = true
             homeMapView.isHidden = true
             addDetails.isHidden = false
       default:
            break
      }
  }
     @IBAction func homeSportButton(_ sender: UIButton) {
       actions.removeAll()
       let sports = ["Cricket", "Football", "Basketball", "Badminton", "Volleyball"]
       for sport in sports {
          let action = UIAlertAction(title: sport, style: .default) { _ in
          let attributedTitle = NSAttributedString(string: "Sport: \(sport)")
//         , attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
          sender.setAttributedTitle(attributedTitle, for: .normal)
        }
           actions.append(action)
     }
           presentActionSheet(title: "Select Sport", message: nil, actions: actions)
  }
    @IBAction func homeRangeButton(_ sender: UIButton) {
        actions.removeAll()
        let range = ["15 miles", "30 miles", "45 miles", "60 miles", "75 miles"]
        for range in range {
           let action = UIAlertAction(title: range, style: .default) { _ in
           let attributedTitle = NSAttributedString(string: "With in: \(range)")
//         , attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
            sender.setAttributedTitle(attributedTitle, for: .normal)
           }
            actions.append(action)
       }
            presentActionSheet(title: "Select Range", message: nil, actions: actions)
   }
    @IBAction func addDetailsLocBtn(_ sender: UIButton) {
        if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
               let userLocation = (UIApplication.shared.delegate as? AppDelegate)?.locationManager.location?.coordinate {
                
                detailController.userLocationCoordinate = userLocation
                   detailController.delegate = self
                   //detailController.setupLocationManager()
                   //locationManager.requestWhenInUseAuthorization()
                   detailController.modalPresentationStyle = .fullScreen
                   detailController.isSearchBarHidden = false
                   detailController.areViewsHidden = true
                   detailController.expandMapHeight = true
                   detailController.isShareButtonHidden = true
                   detailController.isDoneButtonHidden = false
                   detailController.selectedLocationCoordinate = selectedCoordinate
                   detailController.locationSelectedHandler = { [weak self] locationName in
                       self?.addDetailsLocLabel.text = locationName
                       self?.selectedLocation = locationName
                       self?.homeSegmentController.selectedSegmentIndex = 2
              }
                 self.present(detailController, animated: false, completion: nil)
          }
      }
    @IBAction func addDetailDoneButton(_ sender: UIButton) {
        CreateActivityAPICall()
    }
}

//MARK: - Extension TableaView
extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
            footer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        return footer
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as!
        HomeTableViewCell
        let location = locations[indexPath.section]
        cell.locationName = location
        cell.homeTableLocation.text = location
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           if let cell = tableView.cellForRow(at: indexPath) as? HomeTableViewCell,
               let locationName = cell.homeTableLocation.text {
               showLoadingView()
               let geocoder = CLGeocoder()
               geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                   self?.hideLoadingView()
                   guard let self = self,
                       let placemark = placemarks?.first,
                       let locationCoordinate = placemark.location?.coordinate else {
                           cell.accessoryView = nil
                           return
            }
            if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                //detailController.modalPresentationStyle = .fullScreen
                 self.selectedMarker?.map = nil
                 self.selectedMarker = nil
                 detailController.selectedLocationInfo = (name: locationName, coordinate: locationCoordinate)
                 detailController.delegate = self
                 cell.accessoryView = nil
//                 let camera = GMSCameraPosition.camera(withLatitude: locationCoordinate.latitude,                  longitude: locationCoordinate.longitude, zoom: 15)
                  // detailController.detailMapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
                self.navigationController?.pushViewController(detailController, animated: false)
                   }
               }
           }
           tableView.deselectRow(at: indexPath, animated: true)
     }
}
