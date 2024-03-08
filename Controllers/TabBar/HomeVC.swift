//
//  HomeVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/08/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Kingfisher
import Starscream

class HomeVC: UIViewController, GMSMapViewDelegate, DetailViewControllerDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate {
    
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
    var locationManager = CLLocationManager()
    var selectedCoordinate: CLLocationCoordinate2D?
    var actions: [UIAlertAction] = []
    var selectedLocation: String?
    var selectedRegion: GMSVisibleRegion?
    var loadingView: UIView?
    var selectedMarker: GMSMarker?
    var selectedLocationLatitude: Double?
    var selectedLocationLongitude: Double?
    var detailViewController: DetailViewController?
    let textFieldDelegateHelper = TextFieldDelegateHelper<HomeVC>()
    var sports: [Category] = []
    var ages: [Agetype] = []
    var activities: [Activities] = []
    let randomGenders = ["Any", "Male", "Female"]
    let randomParticipants = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "More than 15", "Team"]
    let randomSkills = ["Any", "Expert", "Perfect", "Middle", "Average"]
    var activityID: String?
    var updateCategoryId: String?
    var range: String?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        apiCall { [weak self] result in
               switch result {
               case .success(let categoriesModel):
                   self?.sports = categoriesModel.body.categories
                   self?.ages = categoriesModel.body.agetypes
               case .failure(let error):
                   print("API call error: \(error)")
               }
           }
        hideRangeBtn()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        homeView.isHidden = false
        homeMapView.isHidden = true
        addDetails.isHidden = true
        setupKeyboardDismiss()
        styleViews()
        tabBarController?.delegate = self
        homeMapView.delegate = self
        addDetailsActivity.attributedPlaceholder = NSAttributedString(string: "  Activity Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        sportTypeLabel.textColor = .lightGray
        ageLabel.textColor = .lightGray
        genderLabel.textColor = .lightGray
        participantLabel.textColor = .lightGray
        skillLabel.textColor = .lightGray
        addDetailsLocLabel.textColor = .lightGray
        self.navigationController?.navigationBar.isHidden = true
        setupTapGesture(for: sportTypeView, action: #selector(showSportActionSheet))
        setupTapGesture(for: genderView, action: #selector(showGenderActionSheet))
        setupTapGesture(for: ageView, action: #selector(showAgeActionSheet))
        setupTapGesture(for: participantView, action:
        #selector(showParticipantActionSheet))
        setupTapGesture(for: skillView, action: #selector(showSkillActionSheet))
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshHomeTableView(_:)), for: .valueChanged)
        homeTableView.refreshControl = refreshControl
    }
    func hideRangeBtn() {
        if UserInfo.shared.isUserLoggedIn == false {
            homeRangeBtn.isHidden = true
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            homeSegmentController.selectedSegmentIndex = 0
            homeSegmentControl(homeSegmentController)
        case 1, 2, 3, 4:
            handleLoginIfNotLoggedIn()
        default:
            break
        }
    }
    private func handleLoginIfNotLoggedIn() {
        if UserInfo.shared.isUserLoggedIn == false {
            if let loginNavController = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                loginNavController.modalPresentationStyle = .fullScreen
                self.tabBarController?.selectedIndex = 0
                self.present(loginNavController, animated: false, completion: nil)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        userActivityAPiCall(sportCategoryID: "0", range: range)
    }
    
    //MARK: - API Calling
    func userActivityAPiCall(sportCategoryID: String?, range: String?) {
        let endPoint = APIConstants.Endpoints.getActivities
        var urlString = APIConstants.baseURL + endPoint
        urlString += "?limit=100"
          if let sportCategoryID = sportCategoryID {
              urlString += "&categoryId=\(sportCategoryID)"
          }
        if let range = range {
              urlString += "&distance=\(range)"
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
                self.activities = responseData.body.activities
                print(responseData.body)
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                    self.homeTableView.refreshControl?.endRefreshing()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    func mapApiCall() {
        let endPoint = APIConstants.Endpoints.userActivitiesMap
        let urlString = APIConstants.baseURL + endPoint

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
                let responseData = try decoder.decode(mapActivityModel.self, from: data)
                let activities = responseData.body.activities

                DispatchQueue.main.async {
                    self.homeMapView.clear()

                    var bounds = GMSCoordinateBounds()

                    for activity in activities {
                        if let latitude = Double(activity.latitude),
                           let longitude = Double(activity.longitude) {
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let image = self.createMarkerView(imageURL: activity.catAvatar)
                            marker.icon = image.image
                            marker.map = self.homeMapView
                            
                            bounds = bounds.includingCoordinate(marker.position)
                        }
                    }
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
                    self.homeMapView.moveCamera(update)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
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
      guard let selectedDateAndTime = datePicker?.date,
            let activity = addDetailsActivity.text, !activity.isEmpty,
            let description = addDetailsTextView.text, !description.isEmpty,
            let gender = genderLabel.text,
            let startAge = ageLabel.text,
            let endAge = ageLabel.text,
            let participantNumber = participantLabel.text,
            let skill = skillLabel.text,
            let location = addDetailsLocLabel.text,
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
                "categoryId": self.updateCategoryId ?? "",
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
        ] as [String : Any]
        print(textFields)
        
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
                        UserInfo.shared.isUserLoggedIn = true
                        print("OKKKKK")
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let body = json["body"] as? [String: Any],
                           let activityId = body["activity_id"] as? Int {
                            UserDefaults.standard.set(activityId, forKey: "activityID")
                            if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                                vc.modalPresentationStyle = .fullScreen
                                vc.comingFromCell = false
                                if let latitude = self.selectedLocationLatitude, let longitude = self.selectedLocationLongitude {
                                    vc.selectedLocationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                } else {
                                    vc.selectedLocationCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                                }
                                self.navigationController?.pushViewController(vc, animated: false)
                            }
                        } else {
                            print("Failed to parse JSON or extract activityId")
                        }
                        self.clearTextFields()
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
                self?.updateCategoryId = sport.categoryID
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.sportTypeLabel.textColor = .white
                } else {
                    self?.sportTypeLabel.textColor = .black
                }
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
                 if self?.traitCollection.userInterfaceStyle == .dark {
                     self?.genderLabel.textColor = .white
                 } else {
                     self?.genderLabel.textColor = .black
                 }
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
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.ageLabel.textColor = .white
                } else {
                    self?.ageLabel.textColor = .black
                }
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
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.participantLabel.textColor = .white
                } else {
                    self?.participantLabel.textColor = .black
                }
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
                if self?.traitCollection.userInterfaceStyle == .dark {
                    self?.skillLabel.textColor = .white
                } else {
                    self?.skillLabel.textColor = .black
                }
            }
         actions.append(action)
     }
         presentActionSheet(title: "Select skill", message: nil, actions: actions)
  }
    @objc func refreshHomeTableView(_ sender: UIRefreshControl) {
        userActivityAPiCall(sportCategoryID: "0", range: range)
    }
    func createMarkerView(imageURL: String) -> UIImageView {
        guard var urlComponents = URLComponents(string: imageURL) else {
            fatalError("Invalid image URL")
        }
        urlComponents.scheme = "https"
        guard let secureURL = urlComponents.url else {
            fatalError("Invalid secure image URL")
        }
        let markerView = UIImageView()
        markerView.contentMode = .scaleAspectFit
        markerView.kf.setImage(with: secureURL)
        return markerView
    }
    func styleViews() {
        sportTypeView.applyBorder()
        genderView.applyBorder()
        ageView.applyBorder()
        participantView.applyBorder()
        skillView.applyBorder()
        addDetailsLocation.applyBorder()
        addDetailsActivity.applyBorder()
        addDetailsTextView.applyBorder()
}
    func didSelectLocation(_ locationName: String, _ longitude: Double, _ latitude: Double) {
        DispatchQueue.main.async {
            self.addDetailsLocLabel.text = locationName
            self.addDetailsLocLabel.textColor = UIColor(named: "Black-White")
            self.selectedLocation = locationName
            self.homeSegmentController.selectedSegmentIndex = 2
            self.selectedLocationLatitude = latitude
            self.selectedLocationLongitude = longitude
        }
    }
//    func createLoadingView() {
//        loadingView = UIView(frame: UIScreen.main.bounds)
//        loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        let activityIndicator = UIActivityIndicatorView(style: .large)
//        activityIndicator.center = loadingView!.center
//        loadingView?.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//    }
//    func showLoadingView() {
//        if loadingView == nil {
//            createLoadingView()
//        }
//        loadingView?.isHidden = false
//        view.addSubview(loadingView!)
//    }
//    func hideLoadingView() {
//        loadingView?.removeFromSuperview()
//        loadingView = nil
//    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
 
    func clearTextFields() {
        sportTypeLabel.text = "Select Sport"
        sportTypeLabel.textColor = .lightGray
        addDetailsActivity.text = ""
        addDetailsTextView.text = ""
        genderLabel.text = "Any"
        genderLabel.textColor = .lightGray
        ageLabel.text = "Any"
        ageLabel.textColor = .lightGray
        participantLabel.text = "Any"
        participantLabel.textColor = .lightGray
        skillLabel.text = "Any"
        skillLabel.textColor = .lightGray
        addDetailsLocLabel.text = "Location"
        addDetailsLocLabel.textColor = .lightGray
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
             mapApiCall()
             addDetails.isHidden = true
       case 2:
             homeView.isHidden = true
             homeMapView.isHidden = true
             addDetails.isHidden = false
          if UserInfo.shared.isUserLoggedIn == false {
              if let loginNavController = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                  loginNavController.modalPresentationStyle = .fullScreen
                  homeSegmentController.selectedSegmentIndex = 0
                  homeSegmentControl(homeSegmentController)
                  self.present(loginNavController, animated: false, completion: nil)
              }
          }

       default:
            break
      }
  }
    @IBAction func homeSportButton(_ sender: UIButton) {
        actions.removeAll()
        let all = UIAlertAction(title: "All", style: .default) { [weak self] _ in
            self?.updateCategoryId = "0"
            self?.homeSportBtn.setTitle("  Sport: All  ", for: .normal)
            self?.userActivityAPiCall(sportCategoryID: self?.updateCategoryId, range: self?.range)
        }
        actions.append(all)
        for sport in sports {
            let title = "  Sport: " + sport.title + "  "
            let action = UIAlertAction(title: sport.title, style: .default) { _ in
                self.updateCategoryId = sport.categoryID
                self.homeSportBtn.setTitle(title, for: .normal)
                self.userActivityAPiCall(sportCategoryID: sport.categoryID, range: self.range)
            }
            actions.append(action)
        }
        presentActionSheet(title: "Select Sport", message: nil, actions: actions)
    }
    @IBAction func homeRangeButton(_ sender: UIButton) {
        actions.removeAll()
        let range = ["10 miles", "20 miles", "30 miles", "40 miles", "50 miles", "100 miles"]
        for range in range {
            let action = UIAlertAction(title: range, style: .default) { _ in
                let attributedTitle = NSAttributedString(string: "   With in: \(range)   ", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
                sender.setAttributedTitle(attributedTitle, for: .normal)
                if let selectedRange = Int(range.replacingOccurrences(of: " miles", with: "")) {
                    self.range = String(selectedRange)
                    self.userActivityAPiCall(sportCategoryID: self.updateCategoryId, range: self.range)
              }
           }
            actions.append(action)
        }
        presentActionSheet(title: "Select Range", message: nil, actions: actions)
    }
    @IBAction func addDetailsLocBtn(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
               let userLocation = (UIApplication.shared.delegate as? AppDelegate)?.locationManager.location?.coordinate {
                   vc.userLocationCoordinate = userLocation
                   vc.delegate = self
                   //detailController.setupLocationManager()
                   //locationManager.requestWhenInUseAuthorization()
                   vc.modalPresentationStyle = .fullScreen
                   vc.isSearchBarHidden = false
                   vc.areViewsHidden = true
                   vc.expandMapHeight = true
                   vc.isShareButtonHidden = true
                   vc.isdelButtonHidden = true
                   vc.isDoneButtonHidden = false
                   vc.backBtnHidden = true
                   let selectedText = "Select Location"
                   vc.labelText = selectedText
                   vc.selectedLocationCoordinate = selectedCoordinate
                   vc.locationSelectedHandler = { [weak self] locationName in
                       self?.addDetailsLocLabel.text = locationName
                       self?.selectedLocation = locationName
                       self?.homeSegmentController.selectedSegmentIndex = 2
              }
                 self.detailViewController = vc
                 vc.userCurrentLocationCoordinate = locationManager.location?.coordinate
                 self.present(vc, animated: false, completion: nil)
          }
      }
    @IBAction func addDetailDoneButton(_ sender: UIButton) {
        CreateActivityAPICall()
    }
}

//MARK: - Extension TableaView
extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as!
        HomeTableViewCell
        cell.layer.borderWidth = 3
        if let borderColor = UIColor(named: "ControllerViews") {
            cell.layer.borderColor = borderColor.cgColor
        }
        let activities = activities[indexPath.row]
        cell.titleLabel?.text = activities.ownerTitle
        cell.activityTitle?.text = activities.activity
        cell.dateLabel?.text = activities.date
        cell.timeLabel?.text = activities.time
        cell.homeTableLocation?.text = activities.location
        loadImage(from: activities.catAvatar, into: cell.catAvatarImage)
        loadImage(from: activities.avatar, into: cell.homeTableImage)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let activity = self.activities[indexPath.row]
            if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                self.tabBarController?.tabBar.isHidden = true
                detailController.comingFromCell = false
                detailController.activityID = activity.activityID
                detailController.delegate = self
                self.navigationController?.pushViewController(detailController, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
