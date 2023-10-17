//
//  ActivityVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ActivityVC: UIViewController, DetailViewControllerDelegate {
    
    //MARK: - Variables
    @IBOutlet weak var activitySegmentController: UISegmentedControl!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var pastView: UIView!
    @IBOutlet weak var pendingtableView: UITableView!
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var followingTableView: UITableView!
    @IBOutlet weak var pastTableView: UITableView!
    var receiverID: String?
    var pending: [Current] = []
    var activity: [Current] = []
    var following: [Current] = []
    var past: [Current] = []
    var selectedMarker: GMSMarker?
    var selectedLocationLatitude: Double?
    var selectedLocationLongitude: Double?
    
    //MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        activitiesAPiCall()
        self.navigationController?.navigationBar.isHidden = true
        activitySegmentController.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //segmentApiCall()
    }
    
//    //MARK: - API CAllING
//    func segmentApiCall() {
//        let endPoint = APIConstants.Endpoints.activityMine
//        var urlString = APIConstants.baseURL + endPoint
//        if let receiverID = receiverID {
//                urlString += "?id=" + receiverID
//            } else if let userID = UserDefaults.standard.string(forKey: "userID") {
//                urlString += "?id=" + userID
//            } else {
//                showAlert(title: "Alert", message: "Both receiverID and userID are missing")
//                return
//            }
//        guard let url = URL(string: urlString) else {
//           showAlert(title: "Alert", message: "Invalid URL")
//            return
//        }
//        var request = URLRequest(url: url)
//        if let apikey = UserDefaults.standard.string(forKey: "apikey") {
//            request.addValue(apikey, forHTTPHeaderField: "authorizuser")
//        }
//        request.addValue("ci_session=7b88733d4b8336873c2371ae16760bf4ee9b5b9f", forHTTPHeaderField: "Cookie")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data {
//                    self.updateCounter(with: data)
//                }
//           }
//               task.resume()
//      }
//    func updateCounter(with responseData: Data) {
//        do {
//            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
//               let body = jsonObject["body"] as? [String: Any] {
//                DispatchQueue.main.async {
//                    let pendingRequests = body["pending"] as? Int ?? 0
//                    let currentRequests = body["current"] as? Int ?? 0
//                    let FollowedRequests = body["followed"] as? Int ?? 0
//                    let pastRequests = body["past"] as? Int ?? 0
//                    
//                    self.activitySegmentController.setTitle("Pending(\(pendingRequests))", forSegmentAt: 0)
//                    self.activitySegmentController.setTitle("Current(\(currentRequests))", forSegmentAt: 1)
//                    self.activitySegmentController.setTitle("Following(\(FollowedRequests))", forSegmentAt: 2)
//                    self.activitySegmentController.setTitle("Past(\(pastRequests))", forSegmentAt: 3)
//                }
//            }
//        } catch {
//            print("Error parsing JSON: \(error)")
//        }
//    }
    func activitiesAPiCall(){
        let endPoint = APIConstants.Endpoints.activityMine
        var urlString = APIConstants.baseURL + endPoint
        if let storedUserID = UserDefaults.standard.object(forKey: "userID") as? String {
            urlString += "?id=" + storedUserID
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
                let responseData = try decoder.decode(Model.self, from: data)
                self.pending = responseData.body.pending
                self.activity = responseData.body.current
                self.following = responseData.body.followed
                self.past = responseData.body.past
                print(responseData.body)
                DispatchQueue.main.async {
                    self.pendingtableView.reloadData()
                    self.currentTableView.reloadData()
                    self.followingTableView.reloadData()
                    self.pastTableView.reloadData()
                    self.updateSegmentTitles()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    //MARK: - Actions
    @IBAction func activitySegmentControl(_ sender: UISegmentedControl) {
        switch activitySegmentController.selectedSegmentIndex {
        case 0:
            pendingView.isHidden = false
            currentView.isHidden = true
            followingView.isHidden = true
            pastView.isHidden = true
        case 1:
            pendingView.isHidden = true
            currentView.isHidden = false
            followingView.isHidden = true
            pastView.isHidden = true
        case 2:
            pendingView.isHidden = true
            currentView.isHidden = true
            followingView.isHidden = false
            pastView.isHidden = true
        case 3:
            pendingView.isHidden = true
            currentView.isHidden = true
            followingView.isHidden = true
            pastView.isHidden = false
        default:
            break
        }
     }
    
    //MARK: - Helper Functions
    func didSelectLocation(_ locationName: String) {
        let geocoder = CLGeocoder()
           geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
               if let placemark = placemarks?.first, let locationCoordinate = placemark.location?.coordinate {
                   self?.selectedLocationLatitude = locationCoordinate.latitude
                   self?.selectedLocationLongitude = locationCoordinate.longitude
            }
        }
    }
    func updateSegmentTitles() {
        DispatchQueue.main.async {
            self.activitySegmentController.setTitle("Pending(\(self.pending.count))", forSegmentAt: 0)
            self.activitySegmentController.setTitle("Current(\(self.activity.count))", forSegmentAt: 1)
            self.activitySegmentController.setTitle("Following(\(self.following.count))", forSegmentAt: 2)
            self.activitySegmentController.setTitle("Past(\(self.past.count))", forSegmentAt: 3)
        }
    }
 }
    
   //MARK: - Extension TableView
extension ActivityVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pendingtableView {
            return pending.count
        } else if tableView == currentTableView {
            return activity.count
        } else if tableView == followingTableView {
            return following.count
        } else if tableView == pastTableView {
            return past.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == pendingtableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityPendingCell
            let pending = pending[indexPath.row]
            cell.nameLabel?.text = pending.ownerTitle.rawValue
            cell.activityTitle?.text = pending.activity
            cell.dateLabel?.text = pending.date
            cell.timeLabel?.text = pending.time
            cell.pendingTableLocation?.text = pending.location
            loadImage(from: pending.catAvatar, into: cell.catAvatarImage)
            loadImage(from: pending.avatar, into: cell.pendingTableImage)
            return cell
        } else if tableView == currentTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityCurrentCell
            let current = activity[indexPath.row]
            cell.nameLabel?.text = current.ownerTitle.rawValue
            cell.activityTitle?.text = current.activity
            cell.dateLabel?.text = current.date
            cell.timeLabel?.text = current.time
            cell.currentTableLocation?.text = current.location
            loadImage(from: current.catAvatar, into: cell.catAvatarImage)
            loadImage(from: current.avatar, into: cell.currentTableImage)
             return cell
        } else if tableView == followingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityFollowingCell
            let following = following[indexPath.row]
            cell.nameLabel?.text = following.ownerTitle.rawValue
            cell.activityTitle?.text = following.activity
            cell.dateLabel?.text = following.date
            cell.timeLabel?.text = following.time
            cell.followingTableLocation?.text = following.location
            loadImage(from: following.catAvatar, into: cell.catAvatarImage)
            loadImage(from: following.avatar, into: cell.followingTableImage)
            return cell
        } else if tableView == pastTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityPastCell
            let past = past[indexPath.row]
            cell.NameLabel?.text = past.ownerTitle.rawValue
            cell.activityTitle?.text = past.activity
            cell.dateLabel?.text = past.date
            cell.timeLabel?.text = past.time
            cell.pastTableLocation?.text = past.location
            loadImage(from: past.catAvatar, into: cell.catAvatarImage)
            loadImage(from: past.avatar, into: cell.pastTableImage)
             return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultHeight: CGFloat = 99.0
        if tableView == pendingtableView {
            let cell = tableView.cellForRow(at: indexPath) as? ActivityPendingCell
            if let cell = cell {
                let labelHeight = cell.pendingTableLocation.intrinsicContentSize.height
                if labelHeight > defaultHeight {
                    return UITableView.automaticDimension
                }
            }
            return defaultHeight
        } else if tableView == currentTableView {
            let cell = tableView.cellForRow(at: indexPath) as? ActivityCurrentCell
            if let cell = cell {
                let labelHeight = cell.currentTableLocation.intrinsicContentSize.height
                if labelHeight > defaultHeight {
                    return UITableView.automaticDimension
                }
            }
            return defaultHeight
        } else if tableView == followingTableView {
            let cell = tableView.cellForRow(at: indexPath) as? ActivityFollowingCell
            if let cell = cell {
                let labelHeight = cell.followingTableLocation.intrinsicContentSize.height
                if labelHeight > defaultHeight {
                    return UITableView.automaticDimension
                }
            }
            return defaultHeight
        } else if tableView == pastTableView {
            let cell = tableView.cellForRow(at: indexPath) as? ActivityPastCell
            if let cell = cell {
                let labelHeight = cell.pastTableLocation.intrinsicContentSize.height
                if labelHeight > defaultHeight {
                    return UITableView.automaticDimension
                }
            }
            return defaultHeight
        }
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == pendingtableView {
            let pending = pending[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) as? ActivityPendingCell,
                let locationName = cell.pendingTableLocation.text {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                    guard let self = self,
                        let placemark = placemarks?.first,
                        let locationCoordinate = placemark.location?.coordinate else {
                            cell.accessoryView = nil
                            return
             }
             if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                 detailController.activityID = pending.activityID
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
        } else if tableView == currentTableView {
            let current = activity[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) as? ActivityCurrentCell,
                let locationName = cell.currentTableLocation.text {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                    guard let self = self,
                        let placemark = placemarks?.first,
                        let locationCoordinate = placemark.location?.coordinate else {
                            cell.accessoryView = nil
                            return
             }
             if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                 detailController.activityID = current.activityID
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
        } else if tableView == followingTableView {
            let following = following[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) as? ActivityFollowingCell,
                let locationName = cell.followingTableLocation.text {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                    guard let self = self,
                        let placemark = placemarks?.first,
                        let locationCoordinate = placemark.location?.coordinate else {
                            cell.accessoryView = nil
                            return
             }
             if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                 detailController.activityID = following.activityID
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
        } else {
            let past = past[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) as? ActivityPastCell,
                let locationName = cell.pastTableLocation.text {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(locationName) { [weak self] (placemarks, error) in
                    guard let self = self,
                        let placemark = placemarks?.first,
                        let locationCoordinate = placemark.location?.coordinate else {
                            cell.accessoryView = nil
                            return
             }
             if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                 detailController.activityID = past.activityID
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
