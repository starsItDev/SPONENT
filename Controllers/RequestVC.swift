//
//  RequestVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

class RequestVC: UIViewController, RequestTableViewCellDelegate, RejectedTableViewCellDelegate, AcceptedTableViewCellDelegate {
    
    //MARK: - Variables
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var pendingImage: UIButton!
    @IBOutlet weak var acceptedImage: UIButton!
    @IBOutlet weak var rejectedImage: UIButton!
    @IBOutlet weak var acceptedTableView: UITableView!
    @IBOutlet weak var rejectedTableView: UITableView!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var acceptedView: UIView!
    @IBOutlet weak var rejectedView: UIView!
    @IBOutlet weak var pendingTableHeight: NSLayoutConstraint!
    @IBOutlet weak var acceptedTableHeight: NSLayoutConstraint!
    @IBOutlet weak var rejectedTableHeight: NSLayoutConstraint!
    @IBOutlet weak var pendingViewheight: NSLayoutConstraint!
    @IBOutlet weak var acceptedViewheight: NSLayoutConstraint!
    @IBOutlet weak var rejectedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var chatView: GradientView!

    @IBOutlet weak var chatTextField: UITextField!
    var isImageRotated = false
    var rejectedTableRowCount = 3
    var activityID: String?
    var pending: [Requests] = []
    var accepted: [Requests] = []
    var rejected: [Requests] = []
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        activityRequestAPI()
        requestTableView.rowHeight = UITableView.automaticDimension
        requestTableView.estimatedRowHeight = 135
        acceptedTableView.rowHeight = UITableView.automaticDimension
        acceptedTableView.estimatedRowHeight = 135
        rejectedTableView.rowHeight = UITableView.automaticDimension
        rejectedTableView.estimatedRowHeight = 135
    }
    
   //MARK: - API Functions
    func activityRequestAPI(){
        let endPoint = APIConstants.Endpoints.getActivityRequest
        var urlString = APIConstants.baseURL + endPoint
       
        urlString += "?activityId=" + (self.activityID ?? "")
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
                let responseData = try decoder.decode(ActivtyRequestModel.self, from: data)
                self.pending = responseData.body.pending
                self.accepted = responseData.body.accepted
                self.rejected = responseData.body.rejected
                print(responseData.body)
                DispatchQueue.main.async {
                    if self.pending.count == 0 {
                        self.requestTableView.isHidden = true
                        self.pendingView.isHidden = true
                        self.pendingViewheight.constant = 0
                        self.pendingTableHeight.constant = 0
                    } else {
                        self.requestTableView.isHidden = false
                        self.pendingView.isHidden = false
                        self.pendingViewheight.constant = 45
                        self.requestTableView.reloadData()
                        let contentHeight = self.requestTableView.contentSize.height
                        self.pendingTableHeight.constant = contentHeight
                    }
                    if self.accepted.count == 0 {
                        self.acceptedTableView.isHidden = true
                        self.acceptedView.isHidden = true
                        self.acceptedViewheight.constant = 0
                        self.acceptedTableHeight.constant = 0
                    } else {
                        self.acceptedTableView.isHidden = false
                        self.acceptedView.isHidden = false
                        self.acceptedViewheight.constant = 45
                        self.acceptedTableView.reloadData()
                        let contentHeight = self.acceptedTableView.contentSize.height
                        self.acceptedTableHeight.constant = contentHeight
                    }
                    if self.rejected.count == 0 {
                        self.rejectedTableView.isHidden = true
                        self.rejectedView.isHidden = true
                        self.rejectedViewHeight.constant = 0
                        self.rejectedTableHeight.constant = 0
                    } else {
                        self.rejectedTableView.isHidden = false
                        self.rejectedView.isHidden = false
                        self.rejectedViewHeight.constant = 45
                        self.rejectedTableView.reloadData()
                        let contentHeight = self.rejectedTableView.contentSize.height
                        self.rejectedTableHeight.constant = contentHeight
                    }
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }

    func acceptRequestApi(userID: String) {
        let endPoint = APIConstants.Endpoints.acceptActivity
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
            ["key": "activityId", "value": activityID ?? "", "type": "text"],
            ["key": "userId", "value": userID, "type": "text"]
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
                  self.activityRequestAPI()
                  self.showToast(message: "Successfully accepted")
                  UserDefaults.standard.set(false, forKey: "\(userID)")
                  //self.currentUserID = userID
           }
         }
      }
      task.resume()
   }
    func rejectRequestApi(userID: String) {
        let endPoint = APIConstants.Endpoints.rejectActivity
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
            ["key": "activityId", "value": activityID ?? "", "type": "text"],
            ["key": "userId", "value": userID, "type": "text"]
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
                  self.activityRequestAPI()
                  self.showToast(message: "Successfully rejected")
           }
         }
      }
      task.resume()
   }
    func cancelRequestApi(userID: String) {
        let endPoint = APIConstants.Endpoints.cancelActivity
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
            ["key": "activityId", "value": activityID ?? "", "type": "text"],
            ["key": "userId", "value": userID, "type": "text"]
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
                  self.activityRequestAPI()
                  self.showToast(message: "Cancelled successfully")
           }
         }
      }
      task.resume()
   }
    func deleteRequestApi(userID: String) {
        let endpoint = APIConstants.Endpoints.deleteActivityRequest
        let urlString = APIConstants.baseURL + endpoint

        guard let url = URL(string: urlString) else {
            showAlert(title: "Alert", message: "Invalid URL")
            return
        }
        let parameters = [
          [
            "key": "activityId",
            "value": activityID ?? "",
            "type": "text"
          ], [
            "key": "userId",
            "value": userID,
            "type": "text"
          ]
        ] as [[String: Any]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.setValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
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
                    self.activityRequestAPI()
                    self.showToast(message: "Activity deleted successfully")
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Actions
    @IBAction func requestBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func pendingButton(_ sender: UIButton) {
        isImageRotated.toggle()
        if isImageRotated {
            pendingImage.rotate180Degrees()
            requestTableView.isHidden = true
            pendingTableHeight.constant = 0
        } else {
            pendingImage.transform = CGAffineTransform(rotationAngle: 0)
            requestTableView.isHidden = false
            pendingTableHeight.constant = requestTableView.contentSize.height
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func acceptedButton(_ sender: UIButton) {
        isImageRotated.toggle()
        if isImageRotated {
            acceptedImage.rotate180Degrees()
            acceptedTableView.isHidden = true
            acceptedTableHeight.constant = 0
        } else {
            acceptedImage.transform = CGAffineTransform(rotationAngle: 0)
            acceptedTableView.isHidden = false
            acceptedTableHeight.constant = acceptedTableView.contentSize.height
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func rejectedButton(_ sender: UIButton) {
        isImageRotated.toggle()
        if isImageRotated {
            rejectedImage.rotate180Degrees()
            rejectedTableView.isHidden = true
            rejectedTableHeight.constant = 0
        } else {
            rejectedImage.transform = CGAffineTransform(rotationAngle: 0)
            rejectedTableView.isHidden = false
            rejectedTableHeight.constant = rejectedTableView.contentSize.height
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Helper functions
    func acceptButtonTapped(inCell cell: RequestTableViewCell) {
        let indexPath = self.requestTableView.indexPath(for: cell)
        if let indexPath = indexPath {
            let pendingRequest = pending[indexPath.row]
            let userID = pendingRequest.userID
//            let name = pendingRequest.userName
//            let activityName = pendingRequest.activity
            acceptRequestApi(userID: userID)
//            let message = "\(name) has accepted your request for \(activityName)"
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//            appDelegate.dispatchNotification(message: "\(message)", userID: userID)
        }
    }
    func rejectButtonTapped(inCell cell: RequestTableViewCell) {
        let indexPath = self.requestTableView.indexPath(for: cell)
        if let indexPath = indexPath {
            let rejectedRequest = pending[indexPath.row]
            let userID = rejectedRequest.userID
            rejectRequestApi(userID: userID)
        }
    }
    func chatButtonTapped(inCell cell: RequestTableViewCell) {
        chatView.isHidden = false
        transparentView.isHidden = false
    }
    @IBAction func chatCancelButton(_ sender: UIButton) {
        chatView.isHidden = true
        transparentView.isHidden = true
        chatTextField.text = ""
    }
    
    @IBAction func chatSendButton(_ sender: UIButton) {
    }
    func cancelButtonTapped(inCell cell: AcceptedTableViewCell) {
        let indexPath = self.acceptedTableView.indexPath(for: cell)
        if let indexPath = indexPath {
            let cancelRequest = accepted[indexPath.row]
            let userID = cancelRequest.userID
            cancelRequestApi(userID: userID)
        }
    }
    func deleteButtonTapped(inCell cell: RejectedTableViewCell) {
        let indexPath = self.rejectedTableView.indexPath(for: cell)
        if let indexPath = indexPath {
            let deleteRequest = rejected[indexPath.row]
            let userID = deleteRequest.userID
            deleteRequestApi(userID: userID)
        }
    }
}

  //MARK: - TableView Extension
extension RequestVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == requestTableView {
            return pending.count
        } else if tableView == acceptedTableView {
            return accepted.count
        } else if tableView == rejectedTableView {
            return rejected.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == requestTableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
            cell.delegate = self
            let pending = pending[indexPath.row]
            cell.pendingUserName?.text = pending.userName
            cell.pendingdate?.text = pending.dateTime
            cell.pendingMessage?.text = pending.userMessage
            loadImage(from: pending.userAvatar, into: cell.pendingImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
            cell.autoresizingMask = [.flexibleHeight]
        return cell
        } else if tableView == acceptedTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AcceptedTableViewCell
            cell.delegate = self
            let accepted = accepted[indexPath.row]
            cell.acceptedUserName?.text = accepted.userName
            cell.acceptedDate?.text = accepted.dateTime
            cell.acceptedMessage?.text = accepted.userMessage
            loadImage(from: accepted.userAvatar, into: cell.acceptedImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
            cell.autoresizingMask = [.flexibleHeight]
            return cell
        } else if tableView == rejectedTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RejectedTableViewCell
            cell.delegate = self
            let rejected = rejected[indexPath.row]
            cell.rejectedName?.text = rejected.userName
            cell.rejectedDate?.text = rejected.dateTime
            cell.rejectedMessage?.text = rejected.userMessage
            loadImage(from: rejected.userAvatar, into: cell.rejectedImage)
            cell.layer.borderWidth = 3
            if let borderColor = UIColor(named: "ControllerViews") {
                cell.layer.borderColor = borderColor.cgColor
            }
            cell.autoresizingMask = [.flexibleHeight]
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}

   //MARK: - UIView Extension
extension UIView {
    func rotate180Degrees(duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) {
            self.transform = self.transform.rotated(by: CGFloat.pi)
        }
    }
}
