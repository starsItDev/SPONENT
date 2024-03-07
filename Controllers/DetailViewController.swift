//
//  DetailViewController.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/08/2023.
//
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import SwiftUI

protocol DetailViewControllerDelegate: AnyObject {
    func didSelectLocation(_ locationName: String, _ longitude: Double, _ latitude: Double)
 }
//protocol DetailDelegate: AnyObject {
//    func didTapAddDetailDoneButton()
//}

class DetailViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {

    //MARK: - Variable
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailTitleLbl: UILabel!
    @IBOutlet weak var detailActivityLbl: UILabel!
    @IBOutlet weak var detailDateLbl: UILabel!
    @IBOutlet weak var detailTimeLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailAgeLbl: UILabel!
    @IBOutlet weak var detailSkillLbl: UILabel!
    @IBOutlet weak var detailGenderLbl: UILabel!
    @IBOutlet weak var detailParticipantLbl: UILabel!
    @IBOutlet weak var detailLocationLbl: UILabel!
    @IBOutlet weak var detailSearchBar: UISearchBar!
    @IBOutlet weak var detailViewOne: UIView!
    @IBOutlet weak var detailViewTwo: UIView!
    @IBOutlet weak var detailMapView: GMSMapView!
    @IBOutlet weak var detailMapHeight: NSLayoutConstraint!
    @IBOutlet weak var detailBackLabel: UILabel!
    @IBOutlet weak var detailShareButton: UIButton!
    @IBOutlet weak var detailDoneButton: UIButton!
    @IBOutlet weak var detailProfileImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var requestJoinButton: UIButton!
    @IBOutlet weak var detailBackBtn: UIButton!
    var locationSelectedHandler: ((String) -> Void)?
    weak var delegate: DetailViewControllerDelegate?
//    weak var delegatetwo: DetailDelegate?
    weak var homeVC: HomeVC?
    var locationManager = CLLocationManager()
    var isSearchBarHidden = true
    var areViewsHidden = false
    var expandMapHeight = false
    var isShareButtonHidden = false
    var isdelButtonHidden = false
    var isDoneButtonHidden = true
    var activityID: String?
    var userID: String?
    var isRequestToJoin = true
    var backBtnHidden = false
    var isOwner: Bool = false
    var labelText: String?
    var comingFromCell: Bool = true
    var requestStatus: Int = 0
    var selectedMarker: GMSMarker?
    var selectedRegion: GMSCoordinateBounds?
    var selectedLocationCoordinate: CLLocationCoordinate2D?
    var userLocationCoordinate: CLLocationCoordinate2D?
    var userCurrentLocationCoordinate: CLLocationCoordinate2D?

//    var selectedLocationInfo: (name: String, coordinate: CLLocationCoordinate2D)?
    
    //MARK: - Override Functions
    override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationController?.navigationBar.isHidden = true
      detailSearchBar.isHidden = isSearchBarHidden
      detailViewOne.isHidden = areViewsHidden
      detailViewTwo.isHidden = areViewsHidden
      detailShareButton.isHidden = isShareButtonHidden
      detailSearchBar.delegate = self
      deleteButton.isHidden = isdelButtonHidden
      detailDoneButton.isHidden = isDoneButtonHidden
      detailBackBtn.isHidden = backBtnHidden
      detailMapView.delegate = self
      detailMapView.settings.compassButton = true
      detailMapView.settings.myLocationButton = true
      if let labelText = labelText {
        detailBackLabel.text = labelText
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21, weight: .bold)])
        detailBackLabel.attributedText = attributedText
      }
      if expandMapHeight {
          let screenHeight = UIScreen.main.bounds.size.height
          detailMapHeight.constant = screenHeight
      }
        detailMapView.isMyLocationEnabled = true
//        if let locationInfo = selectedLocationInfo {
//            let coordinate = locationInfo.coordinate
//            let marker = GMSMarker(position: coordinate)
//            marker.title = locationInfo.name
//            marker.map = detailMapView
//            let cameraUpdate = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
//            detailMapView.camera = cameraUpdate
//        }
        if let userLocationCoordinate = userLocationCoordinate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let camera = GMSCameraPosition.camera(withLatitude: userLocationCoordinate.latitude, longitude: userLocationCoordinate.longitude, zoom: 18)
                self.detailMapView.camera = camera
            }
        }
        if let userLocationCoordinate = userCurrentLocationCoordinate {
                let camera = GMSCameraPosition.camera(withTarget: userLocationCoordinate, zoom: 15)
                detailMapView.camera = camera
            }
        if let selectedLocationCoordinate = selectedLocationCoordinate {
            let camera = GMSCameraPosition.camera(withTarget: selectedLocationCoordinate, zoom: 15)
                detailMapView.camera = camera
                let marker = GMSMarker(position: selectedLocationCoordinate)
                marker.title = "Selected Location"
                marker.map = detailMapView
        }
        let userid = UserDefaults.standard.string(forKey: "userID")
        self.isRequestToJoin = UserDefaults.standard.bool(forKey: userid ?? "")
          if self.isRequestToJoin == false {
              requestJoinButton.setTitle("Cancel Request", for: .normal)
         } else {
              requestJoinButton.setTitle("Request to Join", for: .normal)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      return .portrait
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        activityDetailAPICall()
         if let annotation = detailMapView.selectedMarker {
             homeVC?.addDetailsLocLabel.text = annotation.title
         }
    }

    //MARK: - API Calling
    func activityDetailAPICall() {
        let endPoint = APIConstants.Endpoints.activityDetail
        var urlString = APIConstants.baseURL + endPoint
        
        if let currentActivityID = activityID {
               activityID = currentActivityID
           } else if let storedActivityID = UserDefaults.standard.string(forKey: "activityID") {
               activityID = storedActivityID
           }
           if let activityID = activityID {
               urlString += "?activityId=" + activityID
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
              } else if let data = data {
                self.updateData(with: data)
            }
        }
        task.resume()
    }
    func deleteAPICall() {
        let endPoint = APIConstants.Endpoints.deleteActivity
        let urlString = APIConstants.baseURL + endPoint
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let storedUserID = UserDefaults.standard.object(forKey: "userID") as? String
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
       }
       request.addValue("ci_session=117c57138897e041c1da019bb55d6e38d6eade11", forHTTPHeaderField: "Cookie")
        
        let parameters: [[String: Any]] = [
            ["key": "activityId", "value": activityID ?? "", "type": "text"],
            ["key": "userId", "value": storedUserID ?? "", "type": "text"]
        ]
        
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
              self.showAlerttwo(title: "Success", message: "Activity deleted successfully") {
                  self.navigationController?.popViewController(animated: true)
              }
            }
         }
      }
      task.resume()
   }
    func showAlerttwo(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func joinActivityApiCall() {
        let endPoint = APIConstants.Endpoints.joinActivity
        let urlString = APIConstants.baseURL + endPoint
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
    }
       request.addValue("ci_session=117c57138897e041c1da019bb55d6e38d6eade11", forHTTPHeaderField: "Cookie")
        
        let parameters: [[String: Any]] = [
            ["key": "activityId", "value": activityID ?? "", "type": "text"]
        ]
        
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
                self.showAlert(title: "Alert", message: "Successfully requested")
                self.requestJoinButton.setTitle("Cancel Request", for: .normal)
                self.isRequestToJoin = false
                let userid = UserDefaults.standard.string(forKey: "userID")
                UserDefaults.standard.set(self.isRequestToJoin, forKey: userid ?? "")
              }
          }
      }
      task.resume()
   }
    func cancelActivityApiCall() {
        let endPoint = APIConstants.Endpoints.cancelActivity
        let urlString = APIConstants.baseURL + endPoint
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let storedUserID = UserDefaults.standard.object(forKey: "userID") as? String
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
    }
       request.addValue("ci_session=117c57138897e041c1da019bb55d6e38d6eade11", forHTTPHeaderField: "Cookie")
        
        let parameters: [[String: Any]] = [
            ["key": "activityId", "value": activityID!, "type": "text"],
            ["key": "userId", "value": storedUserID!, "type": "text"]
        ]
        
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
                   self.showAlert(title: "Alert", message: "Activity Cancelled Sucessfully \(responseData)")
                  self.requestJoinButton.setTitle("Request to Join", for: .normal)
                  self.isRequestToJoin = true
                  let userid = UserDefaults.standard.string(forKey: "userID")
                  UserDefaults.standard.set(self.isRequestToJoin, forKey: userid ?? "")
              }
          }
      }
      task.resume()
   }
    
    //MARK: - Actions
    @IBAction func detailBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func detailDoneBtnClicked(_ sender: UIButton) {
        let searchedLocation = detailSearchBar.text ?? ""
//        if !searchedLocation.isEmpty {
//            delegate?.didSelectLocation(searchedLocation)
//          } else {
//            delegate?.didSelectLocation("", 0, 0)
//       }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func requestToJoinBtn(_ sender: UIButton) {
        if self.isOwner {
            if self.requestStatus == 0 {
                self.isRequestToJoin = false
                self.requestJoinButton.setTitle("No request yet", for: .normal)
            } else if self.requestStatus > 0 {
                self.isRequestToJoin = false
                self.requestJoinButton.setTitle("View Requests", for: .normal)
                if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RequestVC") as? RequestVC {
                    vc.activityID = self.activityID
                    self.navigationController?.pushViewController(vc, animated: false)
               }
            }
         } else {
             if self.isRequestToJoin {
                 joinActivityApiCall()
             } else {
                 cancelActivityApiCall()
             }
             isRequestToJoin.toggle()
         }
     }
    @IBAction func deleteButton(_ sender: UIButton) {
        deleteAPICall()
    }
    @IBAction func shareButton(_ sender: UIButton) {
        let appStoreLink = URL(string: "https://apps.apple.com")!
        let activityController = UIActivityViewController(activityItems: [appStoreLink], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    //MARK: - Helper Functions
    func updateData(with responseData: Data) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let body = jsonObject["body"] as? [String: Any],
               let latitude = Double(body["latitude"] as? String ?? "0"),
               let longitude = Double(body["longitude"] as? String ?? "0"),
               let locationName = body["location"] as? String {
                DispatchQueue.main.async {
                    self.detailTitleLbl.text = body["owner_title"] as? String
                    self.detailActivityLbl.text = body["activity"] as? String
                    self.detailDateLbl.text = body["date"] as? String
                    self.detailTimeLbl.text = body["time"] as? String
                    self.descriptionLabel.text = body["description"] as? String
                    self.detailAgeLbl.text = body["start_age"] as? String
                    self.detailSkillLbl.text = body["skill"] as? String
                    self.detailGenderLbl.text = body["gender"] as? String
                    self.detailParticipantLbl.text = body["number"] as? String
                    self.detailLocationLbl.text = locationName
                    self.selectedLocationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                    self.selectedLocationInfo = (name: locationName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    if let selectedLocationCoordinate = self.selectedLocationCoordinate {
                        let camera = GMSCameraPosition.camera(withTarget: selectedLocationCoordinate, zoom: 15)
                        self.detailMapView.camera = camera
                            let marker = GMSMarker(position: selectedLocationCoordinate)
                            marker.title = "Selected Location"
                        marker.map = self.detailMapView
                    }
                    self.activityID = body["activity_id"] as? String
                    self.userID = body["owner_id"] as? String
                    if let avatarURLString = body["avatar"] as? String {
                        self.loadImage(from: avatarURLString, into: self.detailProfileImage, placeholder: UIImage(named: "placeholderImage"))
                    }
                    if let isOwnerValue = body["is_owner"] as? Bool {
                        self.isOwner = isOwnerValue
                    }
                    if let requestStatusValue = body["request_status"] as? Int {
                        self.requestStatus = requestStatusValue
                    }
                    if self.isOwner == true {
                        if self.requestStatus == 0 {
                        self.requestJoinButton.titleLabel?.text = "No request yet"
                    } else if self.requestStatus > 0 {
                        self.requestJoinButton.titleLabel?.text = "View Requests"
                    }
                    if self.isdelButtonHidden == false {
                        self.deleteButton.isHidden = false
                    }
                    } else {
                        if self.isRequestToJoin{
                           self.requestJoinButton.titleLabel?.text = "Request To join"
                        } else {
                           self.requestJoinButton.titleLabel?.text = "Cancel request"
                        }
                    self.deleteButton.isHidden = true
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
       }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       searchBar.resignFirstResponder()
       guard let searchText = searchBar.text, !searchText.isEmpty
        else {
           return
         }
        let filter = GMSAutocompleteFilter()
        filter.types = ["address"]
        let sessionToken = GMSAutocompleteSessionToken.init() 
        let placesClient = GMSPlacesClient.shared()
        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, sessionToken: sessionToken) { [weak self] (results, error) in
        guard let self = self
            else {
               return
        }
             if let error = error {
                print("Error in autocomplete: \(error.localizedDescription)")
                return
        }
              if let prediction = results?.first {
                  let placeID = prediction.placeID
                  let placesClient = GMSPlacesClient.shared()
                  placesClient.lookUpPlaceID(placeID) { [weak self] (place, placeError) in
              guard let self = self
                    else {
                        return
                    }
              if let placeError = placeError {
                    print("Error in place lookup: \(placeError.localizedDescription)")
                    return
              }
                      if let place = place {
                         let coordinate = place.coordinate
                         self.selectedMarker?.map = nil
                         self.selectedMarker = GMSMarker(position: coordinate)
                         self.selectedMarker?.title = place.name
                         self.selectedMarker?.map = self.detailMapView
                         let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 15)
                         self.detailMapView.animate(with: cameraUpdate)
                    }
                }
            }
        }
    }
//  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//            if let locationName = marker.title {
//                delegate?.didSelectLocation(locationName)
//                //dismiss(animated: true, completion: nil)
//            }
//            return true
//        }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
           let geocoder = GMSGeocoder()
           geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] (response, error) in
               guard let self = self, let result = response?.firstResult() else {
                   return
            }
               let locationName = result.lines?.joined(separator: ", ") ?? ""
               self.delegate?.didSelectLocation(locationName, coordinate.longitude, coordinate.latitude)
               if self.comingFromCell {
                    self.dismiss(animated: true, completion: nil)
              } else {
                  print("comingFromCell == false")
            }
        }
    }
}
