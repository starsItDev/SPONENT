//
//  ConnectVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 08/09/2023.
//

import UIKit
import Starscream
import Kingfisher

class ConnectVC: UIViewController, ConnectTableViewCellDelegate, UITextFieldDelegate {

    //MARK: - Variables
    @IBOutlet weak var connectTableView: UITableView!
    @IBOutlet weak var chatView: GradientView!
    @IBOutlet weak var chatTextField: UITextField!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ConnectVC>()
    var connections: [Connection] = []
    var selectedReceiverID: String?
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        connectionAPICall()
        chatView.isHidden = true
        chatTextField.layer.cornerRadius = 5
        chatTextField.layer.borderWidth = 1.0
        chatTextField.layer.borderColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - API Call
    func connectionAPICall() {
        let endPoint = APIConstants.Endpoints.connection
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
                let responseData = try decoder.decode(ConnectModel.self, from: data)
                self.connections = responseData.body.connections
                print(responseData.body)
                DispatchQueue.main.async {
                    self.connectTableView.reloadData()
                }
            }
            catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    //MARK: - Helper functions
    func chatImageViewTapped(in cell: ConnectTableViewCell) {
            chatView.isHidden = false
    }
    func setupKeyboardDismiss() {
           textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    
    //MARK: - Actions
    @IBAction func chatCancelButton(_ sender: UIButton) {
        chatView.isHidden = true
    }
}

 //MARK: - Extension TableView
 extension ConnectVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConnectTableViewCell
        let connection = connections[indexPath.row]
        cell.connectCellLabel?.text = connection.title
        if let avatarURL = URL(string: connection.photoURL) {
              loadImage(from: avatarURL.absoluteString, into: cell.connectImageView, placeholder: UIImage(named: "placeholderImage"))
          } else {
              print("Invalid image URL: \(connection.photoURL)")
          }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultHeight: CGFloat = 99.0
        let cell = tableView.cellForRow(at: indexPath) as? ConnectTableViewCell
        if let cell = cell {
            let labelHeight = cell.connectCellLabel.intrinsicContentSize.height
            if labelHeight > defaultHeight {
                return UITableView.automaticDimension
            }
        }
        return defaultHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatView.isHidden = true
        let conversation = connections[indexPath.row]
        selectedReceiverID = conversation.userID
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            vc.delegate = self
            vc.isProfileBackButtonHidden = false
            vc.isFollowButtonHidden = false
            vc.receiverID = conversation.userID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

  //MARK: - Extension ProfileDelegate
  extension ConnectVC: ProfileDelegate {
      
    func didTapUserProfileSettingButton() {
       if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
           if profileVC.userSettingStackView.isHidden {
              profileVC.userSettingStackView.isHidden = false
              profileVC.settingStackView.isHidden = true
           } else {
              profileVC.userSettingStackView.isHidden = true
              profileVC.settingStackView.isHidden = true
          }
       }
   }
}

