
//
//  ChatViewVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 14/09/2023.
//

import UIKit
class ChatVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var chatProfileImage: UIImageView!
    
    // MARK: - Variable
    let textFieldDelegateHelper = TextFieldDelegateHelper<ChatVC>()
    var messages: [Message] = []
    var message: MessageModelBody?
    var receiverName: String?
    var receiverID: Int?
    var selectedReceiverID: String?
    
    // MARK: - Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        messageApiCall()
        tableView.dataSource = self
        setupKeyboardDismiss()
        messageTextField.applyBorder()
    }
    
    // MARK: - Helper Function
    func setupKeyboardDismiss() {
        if let name = receiverName {
            userNameLbl.text = name
        }
        self.navigationController?.navigationBar.isHidden = true
        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
    }
    func updateChat(message: Message) {
        messages.append(message)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Actions
    @IBAction func sendMessage(_ sender: Any) {
        guard let message = messageTextField.text, !message.isEmpty,
              let receiverID = receiverID,
              let apiKey = UserDefaults.standard.string(forKey: "apikey") else {
            print("Invalid input or missing data")
            return
        }
        let receiverId = String(receiverID)
        let endpoint = APIConstants.Endpoints.sendMessage
        let urlString = APIConstants.baseURL + endpoint
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        request.addValue("ci_session=ccc2acfac2a1fb3185e0be8f31e32b74548eaaf2", forHTTPHeaderField: "Cookie")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = ""
        let parameters: [[String: Any]] = [
            ["key": "receiverId", "value": receiverId, "type": "text"],
            ["key": "message", "value": message, "type": "text"]
        ]

        for param in parameters {
            guard let paramName = param["key"] as? String, let paramValue = param["value"] as? String else {
                continue
            }
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            body += "\r\n\r\n\(paramValue)\r\n"
        }

        body += "--\(boundary)--\r\n"
        request.httpBody = body.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse, error == nil {
                if response.statusCode == 200 {
                    if let responseData = String(data: data, encoding: .utf8) {
                        print("Response Data: \(responseData)")
                        
                    }
                } else {
                    print("HTTP Status Code: \(response.statusCode)")
                }
            } else {
                print("Error: \(String(describing: error))")
            }
        }
        task.resume()
        messageTextField.text = ""
        tableView.reloadData()
        messageApiCall()
    }
    
   //MARK: - API Call
    func messageApiCall() {
        guard let receiverID = receiverID else {
            print("Receiver ID is nil or invalid")
            return
        }

        let receiverId = String(receiverID)
        let endpoint = APIConstants.Endpoints.messages
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

        request.addValue("ci_session=2af35aba20c6238d5d8617ac781af0a1aefb0537", forHTTPHeaderField: "Cookie")

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""

        body += "--\(boundary)\r\n"
        body += "Content-Disposition: form-data; name=\"receiverId\"\r\n\r\n"
        body += "\(receiverId)\r\n"
        body += "--\(boundary)--\r\n"

        let postData = body.data(using: .utf8)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
            if response.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(MessageModel.self, from: data)
                    let receivedMessages = responseData.body.messages
                    for receivedMessage in receivedMessages {
                        self.updateChat(message: receivedMessage)
                    }
                    let image = responseData.body.userAvatar
                    self.loadImage(from: image, into: self.chatProfileImage, placeholder: nil)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        task.resume()
    }
}
  //MARK: - TableView
  extension ChatVC: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let message = messages[indexPath.row]
          let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCellUser", for: indexPath) as! MessageCellUser
              cell.chatLabel?.text = message.body
          let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
              if let date = dateFormatter.date(from: message.date) {
                 dateFormatter.dateFormat = "hh:mm a"
                 let formattedDate = dateFormatter.string(from: date)
                 cell.dateLabel?.text = formattedDate
             } else {
                 print("Invalid date: \(message.date)")
             }
        return cell
      }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
    }
}
  //MARK: Button Actions
  extension ChatVC {
      @IBAction func userProfileButton(_ sender: UIButton) {
            let message = message
            selectedReceiverID = message?.userID
            if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                  vc.delegate = self
                  vc.isProfileBackButtonHidden = false
                  vc.isFollowButtonHidden = false
                  vc.receiverID = message?.userID
                  self.navigationController?.pushViewController(vc, animated: true)
          }
      }
    @IBAction func chatBackButton(_ sender: UIButton) {
        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.selectedIndex = 3
            self.present(tabBarController, animated: false)
         }
    }
}
  //MARK: - Extension ProfileDelegate
  extension ChatVC: ProfileDelegate {
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

//import UIKit
//import SocketIO
//
//class ChatVC: UIViewController, UITableViewDataSource{
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var messageTextField: UITextField!
//    @IBOutlet weak var sendButton: UIButton!
//    let textFieldDelegateHelper = TextFieldDelegateHelper<ChatVC>()
//
//    var messages: [String] = []
//    let manager = SocketManager(socketURL: URL(string: "https://social.untamedoutback.com.au:3000")!, config: [.log(false), .connectParams(["uid": 1]), .compress])
//    lazy var socket = manager.defaultSocket
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//        setupKeyboardDismiss()
//        // Listen for socket connection event
//        socket.on(clientEvent: .connect) { data, ack in
//            print("Socket connected")
//        }
//        socket.on("chat message") { data, ack in
//            print("Received chat message event with data: \(data)")
//            if let message = data[0] as? String {
//                self.updateChat(message: message)
//            }
//        }
//        socket.connect()
//        print("Socket status: \(socket.status)")
//    }
//    //MARK: - Actions
//    @IBAction func userProfileButton(_ sender: UIButton) {
//        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
//            vc.delegate = self
//            vc.isProfileBackButtonHidden = false
//            vc.isFollowButtonHidden = false
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//    @IBAction func chatBackButton(_ sender: UIButton) {
//        if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
//            tabBarController.modalPresentationStyle = .fullScreen
//            tabBarController.selectedIndex = 3
//            self.present(tabBarController, animated: false)
//         }
//     }
//    func setupKeyboardDismiss() {
//        textFieldDelegateHelper.configureTapGesture(for: view, in: self)
//    }
//    func updateChat(message: String) {
//        messages.append(message)
//        tableView.reloadData()
//    }
//    @IBAction func sendMessage(_ sender: Any) {
//        if let message = messageTextField.text, !message.isEmpty {
//            socket.emit("chat message", message)
//            messageTextField.text = ""
//            updateChat(message: "You: \(message)")
//        }
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
//        cell.textLabel?.text = messages[indexPath.row]
//        return cell
//    }
//}
//


//
//
//import UIKit
//import SocketIO
//struct ChatMessage {
//    let content: String
//    let userID: String
//}
//
//class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var messageTextField: UITextField!
//    @IBOutlet weak var sendButton: UIButton!
//
//    var messages: [String] = []
//    let socket = SocketManager(socketURL: URL(string: "https://social.untamedoutback.com.au:3000")!).defaultSocket
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        socket.on("chat message") { data, ack in
//            if let messageData = data.first as? [String: Any],
//               let content = messageData["content"] as? String,
//               let userID = messageData["userID"] as? String {
//
//                // Create a ChatMessage object with the received message and user ID
//                let chatMessage = ChatMessage(content: content, userID: userID)
//
//                // Add the received message to the local messages array
//                self.messages.append(chatMessage)
//
//                // Reload the table view to display the received message
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//
//                    // Scroll to the newly received message
//                    if self.messages.count > 0 {
//                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
//                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                    }
//                }
//            }
//        }
//
//        // Connect to the Socket.IO server
//        socket.connect()
//        print("Initial message count: \(self.messages.count)")
//    }
//
//    @IBAction func sendMessage(_ sender: UIButton) {
//        if let message = messageTextField.text, !message.isEmpty, let userID = currentUserID {
//            // Create a ChatMessage object with the message and user ID
//            let chatMessage = ChatMessage(content: message, userID: userID)
//
//            // Add the sent message to the local messages array
//            messages.append(chatMessage)
//
//            // Reload the table view to display the sent message
//            let indexPath = IndexPath(row: messages.count - 1, section: 0)
//            tableView.insertRows(at: [indexPath], with: .automatic)
//
//            // Scroll to the newly sent message
//            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//
//            // Emit the message and user ID to the server
//            socket.emit("chat message", ["content": message, "userID": userID])
//
//            // Clear the text field
//            messageTextField.text = ""
//        }
//    }
//
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
//        cell.textLabel?.text = messages[indexPath.row]
//        return cell
//    }
//
//    // Handle disconnections and reconnects if needed
//       func handleDisconnect() {
//           socket.on(clientEvent: .disconnect) { data, _ in
//               // Handle disconnection
//           }
//
//           socket.on(clientEvent: .reconnect) { data, _ in
//               // Handle reconnection
//           }
//       }
//   }
//
//  ChatVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 14/09/2023.
//
//
//import UIKit
//import MessageKit
//import InputBarAccessoryView
//
//  //MARK: - Structures
//struct User: SenderType {
//    var senderId: String
//    var displayName: String
//}
// struct Message: MessageType{
//    var sender: SenderType
//    var messageId: String
//    var sentDate: Date
//    var kind: MessageKind
//}
//
//    //MARK: - Class ChatVC
//class ChatVC: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate,                       MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
//    
//    //MARK: - Variables
//     let user: User = User(senderId: "user1", displayName: "Guest")
//     let opponent: User = User(senderId: "user2", displayName: "John")
//     var messages: [Message] = []
//     var receivedMessages: [Message] = []
//    
//    //MARK: - Override Function
//     override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.navigationBar.isHidden = true
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.reloadData()
//        messagesCollectionView.scrollToLastItem(animated: true)
//        addRandomMessages()
//        messageInputBar.delegate = self
//    }
//    
//    //MARK: - Helper Functions
//    func addRandomMessages() {
//        let message1 = Message(sender: user, messageId: "1", sentDate: Date(), kind: .text("Hello, how are you?"))
//        let message2 = Message(sender: opponent, messageId: "2", sentDate: Date(), kind: .text("I'm good, thanks!"))
//        messages.append(contentsOf: [message1, message2])
//        receivedMessages = messages
//        messagesCollectionView.reloadData()
//    }
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let senderName = message.sender.displayName
//        if message.sender.senderId == user.senderId {
//        return NSAttributedString(string: senderName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.blue])
//        } else {
//        return NSAttributedString(string: senderName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.red])
//        }
//    }
//    var currentSender: SenderType {
//           return user
//    }
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return receivedMessages[indexPath.section]
//    }
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return receivedMessages.count
//    }
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        if message.sender.senderId == user.senderId {
//            return UIColor.orange
//        } else {
//            return UIColor.init(red: 0, green: 0, blue: 2, alpha: 0.3)
//        }
//    }
//    func messageBackgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
//    }
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//            let newMessage = Message(sender: user, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
//            messages.append(newMessage)
//            receivedMessages = messages
//            messagesCollectionView.reloadData()
//            inputBar.inputTextView.text = ""
//            messagesCollectionView.scrollToLastItem(animated: true)
//    }
//}
