//
//  MessagesVC.swift
//  SPONENT
//  Created by Rao Ahmad on 13/09/2023.
//
//
//

import UIKit
import Kingfisher

class MessagesVC: UIViewController {
    
    //MARK: - Variables
    @IBOutlet weak var messageTableView: UITableView!
    var conversations: [Conversation] = []
    var selectedReceiverID: Int?
   
    //MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InboxapiCall()
        self.navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
        navigationController?.view.backgroundColor = .clear

    }
    //MARK: - API Call
    func InboxapiCall() {
        var request = URLRequest(url: URL(string: "https://playwithmeapp.com/api/app/inbox")!, timeoutInterval: Double.infinity)
        if let apiKey = UserDefaults.standard.string(forKey: "apikey") {
            request.addValue(apiKey, forHTTPHeaderField: "authorizuser")
        }
        request.addValue("ci_session=dca13b75c98d0a3adb35f00b8a053c47e285d746", forHTTPHeaderField: "Cookie")
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
              do {
                 let decoder = JSONDecoder()
                 let responseData = try decoder.decode(InboxModel.self, from: data)
                 self.conversations = responseData.body.conversations

                 DispatchQueue.main.async {
                     self.messageTableView.reloadData()
                 }
              } catch {
                  print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
}

 //MARK: - Extension TableView
 extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagesTableViewCell
        let conversation = conversations[indexPath.row]
        cell.messageNameLabel?.text = conversation.nameReceiver
        cell.messageChatLabel?.text = conversation.message
        cell.layer.borderWidth = 3
        if let borderColor = UIColor(named: "ControllerViews") {
            cell.layer.borderColor = borderColor.cgColor
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: conversation.date) {
            dateFormatter.dateFormat = "hh:mm a"
            let formattedDate = dateFormatter.string(from: date)
            cell.messagetimeLabel?.text = formattedDate
        } else {
            cell.messagetimeLabel?.text = ""
        }
        loadImage(from: conversation.avatarReceiver, into: cell.messageIMageView, placeholder: UIImage(named: "placeholderImage"))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        selectedReceiverID = conversation.receiverID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            self.tabBarController?.tabBar.isHidden = true
             chatController.messageSenderName = conversation.nameReceiver
             chatController.messageSenderImage = conversation.avatarReceiver
            // Assuming chatController.receiverID is of type String?
            chatController.receiverID = String(conversation.receiverID)
              navigationController?.pushViewController(chatController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         //return UITableView.automaticDimension
         return 100
    }
}
