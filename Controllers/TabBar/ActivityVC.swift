//
//  ActivityVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ActivityVC: UIViewController {
    
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
        self.navigationController?.navigationBar.isHidden = true
        activitySegmentController.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        activitiesAPiCall()
        self.tabBarController?.tabBar.isHidden = false
    }

    //MARK: - API CAllING
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
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(Model.self, from: data)
                    self.pending = responseData.body.pending
                    self.activity = responseData.body.current
                    self.following = responseData.body.followed
                    self.past = responseData.body.past
                    print(responseData.body)
                    self.pendingtableView.reloadData()
                    self.currentTableView.reloadData()
                    self.followingTableView.reloadData()
                    self.pastTableView.reloadData()
                    self.updateSegmentTitles()
                }
                catch {
                    print("Error decoding JSON: \(error)")
                }
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
            cell.nameLabel?.text = pending.ownerTitle
            cell.activityTitle?.text = pending.activity
            cell.dateLabel?.text = pending.date
            cell.timeLabel?.text = pending.time
            cell.pendingTableLocation?.text = pending.location
            loadImage(from: pending.catAvatar, into: cell.catAvatarImage)
            loadImage(from: pending.avatar, into: cell.pendingTableImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
            return cell
        } else if tableView == currentTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityCurrentCell
            let current = activity[indexPath.row]
            cell.nameLabel?.text = current.ownerTitle
            cell.activityTitle?.text = current.activity
            cell.dateLabel?.text = current.date
            cell.timeLabel?.text = current.time
            cell.currentTableLocation?.text = current.location
            loadImage(from: current.catAvatar, into: cell.catAvatarImage)
            loadImage(from: current.avatar, into: cell.currentTableImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
             return cell
        } else if tableView == followingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityFollowingCell
            let following = following[indexPath.row]
            cell.nameLabel?.text = following.ownerTitle
            cell.activityTitle?.text = following.activity
            cell.dateLabel?.text = following.date
            cell.timeLabel?.text = following.time
            cell.followingTableLocation?.text = following.location
            loadImage(from: following.catAvatar, into: cell.catAvatarImage)
            loadImage(from: following.avatar, into: cell.followingTableImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
            return cell
        } else if tableView == pastTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityPastCell
            let past = past[indexPath.row]
            cell.NameLabel?.text = past.ownerTitle
            cell.activityTitle?.text = past.activity
            cell.dateLabel?.text = past.date
            cell.timeLabel?.text = past.time
            cell.pastTableLocation?.text = past.location
            loadImage(from: past.catAvatar, into: cell.catAvatarImage)
            loadImage(from: past.avatar, into: cell.pastTableImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
             return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
//  let defaultHeight: CGFloat = 99.0
//        if tableView == pendingtableView {
//            let cell = tableView.cellForRow(at: indexPath) as? ActivityPendingCell
//            if let cell = cell {
//                let labelHeight = cell.pendingTableLocation.intrinsicContentSize.height
//                if labelHeight > defaultHeight {
//                    return UITableView.automaticDimension
//                }
//            }
//            return defaultHeight
//        } else if tableView == currentTableView {
//            let cell = tableView.cellForRow(at: indexPath) as? ActivityCurrentCell
//            if let cell = cell {
//                let labelHeight = cell.currentTableLocation.intrinsicContentSize.height
//                if labelHeight > defaultHeight {
//                    return UITableView.automaticDimension
//                }
//            }
//            return defaultHeight
//        } else if tableView == followingTableView {
//            let cell = tableView.cellForRow(at: indexPath) as? ActivityFollowingCell
//            if let cell = cell {
//                let labelHeight = cell.followingTableLocation.intrinsicContentSize.height
//                if labelHeight > defaultHeight {
//                    return UITableView.automaticDimension
//                }
//            }
//            return defaultHeight
//        } else if tableView == pastTableView {
//            let cell = tableView.cellForRow(at: indexPath) as? ActivityPastCell
//            if let cell = cell {
//                let labelHeight = cell.pastTableLocation.intrinsicContentSize.height
//                if labelHeight > defaultHeight {
//                    return UITableView.automaticDimension
//                }
//            }
//            return defaultHeight
//        }
//        return 0
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == pendingtableView {
            let pending = pending[indexPath.row]
            if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                self.tabBarController?.tabBar.isHidden = true
                detailController.comingFromCell = false
                detailController.activityID = pending.activityID
                self.selectedMarker?.map = nil
                self.selectedMarker = nil
                self.navigationController?.pushViewController(detailController, animated: false)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView == currentTableView {
            let current = activity[indexPath.row]
            if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                self.tabBarController?.tabBar.isHidden = true
                detailController.comingFromCell = false
                detailController.activityID = current.activityID
                self.selectedMarker?.map = nil
                self.selectedMarker = nil
                self.navigationController?.pushViewController(detailController, animated: false)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView == followingTableView {
            let following = following[indexPath.row]
            if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                self.tabBarController?.tabBar.isHidden = true
                detailController.comingFromCell = false
                detailController.activityID = following.activityID
                self.selectedMarker?.map = nil
                self.selectedMarker = nil
                self.navigationController?.pushViewController(detailController, animated: false)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let past = past[indexPath.row]
            if let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                self.tabBarController?.tabBar.isHidden = true
                detailController.comingFromCell = false
                detailController.activityID = past.activityID
                self.selectedMarker?.map = nil
                self.selectedMarker = nil
                self.navigationController?.pushViewController(detailController, animated: false)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
