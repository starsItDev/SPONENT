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
    @IBOutlet weak var transparentView: UIView!
    let textFieldDelegateHelper = TextFieldDelegateHelper<ConnectVC>()
    var connections: [Connection] = []
    var selectedReceiverID: String?
    
    let socketManager = SocketIOManager.sharedInstance
    var chatMessages: [ChatMessage] = []
    var accessToken = "2a5b7d1b0f6a4ff9341d60d1eb2cef12c7be12d00e9be368a6afb6f9a044c9cd83f58619323925141ce4fe042832e6bd7d06697a43055373"
    var userName = "raoahmad"
    var sendMessagetoID = "31136"

    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        chatView.isHidden = true
        chatTextField.layer.cornerRadius = 5
        chatTextField.layer.borderWidth = 1.0
        chatTextField.layer.borderColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        connectionAPICall()
        self.tabBarController?.tabBar.isHidden = false
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
        transparentView.isHidden = false
    }
    func setupKeyboardDismiss() {
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    
    //MARK: - Actions
    @IBAction func chatCancelButton(_ sender: UIButton) {
        chatView.isHidden = true
        transparentView.isHidden = true
        chatTextField.text = ""
    }
    func joinSocket() {
        let recipientID = ""
        let userID = accessToken
        let messageID = ""
        socketManager.joinSocket(recipientID: recipientID, userID: userID, messageID: messageID) { success in
            if success {
                print("Join event sent successfully!")
            } else {
                print("Failed to send join event.")
            }
        }
    }
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        joinSocket()
        if socketManager.isSocketConnected {
            if let messageText = chatTextField.text, !messageText.isEmpty {
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                let currentTimeString = dateFormatter.string(from: currentDate)
                socketManager.sendPrivateMessage(
                    toID: sendMessagetoID,
                    fromID: accessToken,
                    username: userName,
                    message: messageText,
                    color: "#056bba",
                    isSticker: false,
                    messageReplyID: ""
                ){ success in
                    if success {
                        print("Private message sent successfully!")
                    } else {
                        print("Failed to send private message.")
                    }
                }
                socketManager.sendTypingDoneEvent(recipientID: sendMessagetoID, userID: accessToken)
                let chatMessage = ChatMessage(message: messageText, time: currentTimeString, senderId: "")
                chatMessages.append(chatMessage)
                chatTextField.resignFirstResponder()
                chatTextField.text = ""
                chatView.isHidden = true
                transparentView.isHidden = true
                showToast(message: "Message Sent")
            } else {
                print("Message text is empty.")
            }
        } else {
            print("Socket is not connected.")
        }
    }
}

 //MARK: - Extension TableView
 extension ConnectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConnectTableViewCell
        cell.delegate = self
        cell.layer.borderWidth = 3
        if let borderColor = UIColor(named: "ControllerViews") {
            cell.layer.borderColor = borderColor.cgColor
        }
        let connection = connections[indexPath.row]
        cell.connectCellLabel?.text = connection.title
        loadImage(from: connection.photoURL , into: cell.connectImageView)
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
        transparentView.isHidden = true
        let conversation = connections[indexPath.row]
        selectedReceiverID = conversation.userID
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            self.tabBarController?.tabBar.isHidden = true
            vc.delegate = self
            vc.isProfileBackButtonHidden = false
            vc.isFollowButtonHidden = false
            vc.receiverID = conversation.userID
            let selectedText = "Profile"
            vc.labelText = selectedText
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

