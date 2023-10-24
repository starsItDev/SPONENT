//
//  RequestVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 11/09/2023.
//

import UIKit

class RequestVC: UIViewController, RequestTableViewCellDelegate, RejectedTableViewCellDelegate {

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
    var isImageRotated = false
    var rejectedTableRowCount = 3
    var pending: [Requests] = []
    var accepted: [Requests] = []
    var rejected: [Requests] = []
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        activityRequestAPI()
//      acceptedViewheight.constant = 0
//      acceptedTableHeight.constant = 0
//      rejectedViewHeight.constant = 0
//      rejectedTableHeight.constant = 0
    }
    
   //MARK: - API Functions
    func activityRequestAPI(){
        let endPoint = APIConstants.Endpoints.getActivityRequest
        var urlString = APIConstants.baseURL + endPoint

        if let storedActivityID = UserDefaults.standard.string(forKey: "activityID"){
            urlString += "?activityId=" + storedActivityID
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
                let responseData = try decoder.decode(ActivtyRequestModel.self, from: data)
                self.pending = responseData.body.pending
                self.accepted = responseData.body.accepted
                self.rejected = responseData.body.rejected
                print(responseData.body)
                DispatchQueue.main.async {
                    self.requestTableView.reloadData()
                    self.acceptedTableView.reloadData()
                    self.rejectedTableView.reloadData()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
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
            pendingTableHeight.constant = 280
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
            acceptedTableHeight.constant = 280
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
            rejectedTableHeight.constant = 280
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func acceptButtonTapped(inCell cell: RequestTableViewCell) {
        acceptedView.isHidden = false
        acceptedTableView.isHidden = false
    }
    func rejectButtonTapped(inCell cell: RequestTableViewCell) {
        if rejectedTableRowCount > 0 {
           rejectedView.isHidden = false
           rejectedTableView.isHidden = false
        }
    }
    func deleteButtonTapped(inCell cell: RejectedTableViewCell) {
        if rejectedTableRowCount > 0 {
            rejectedTableRowCount -= 1
            rejectedTableView.reloadData()
            
            if rejectedTableRowCount == 0 {
                rejectedView.isHidden = true
                rejectedTableView.isHidden = true
            }
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
            cell.layer.borderColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
        return cell
        } else if tableView == acceptedTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AcceptedTableViewCell
            //cell.delegate = self
            let accepted = accepted[indexPath.row]
            cell.acceptedUserName?.text = accepted.userName
            cell.acceptedDate?.text = accepted.dateTime
            cell.acceptedMessage?.text = accepted.userMessage
            loadImage(from: accepted.userAvatar, into: cell.acceptedImage)
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
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
            cell.layer.borderColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
