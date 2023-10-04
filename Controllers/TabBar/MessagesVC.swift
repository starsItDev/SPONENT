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
        InboxapiCall()
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
        cell.messagetimeLabel?.text = conversation.date
        if let avatarURL = URL(string: conversation.avatarReceiver) {
              loadImage(from: avatarURL.absoluteString, into: cell.messageIMageView, placeholder: UIImage(named: "placeholderImage"))
          } else {
              print("Invalid image URL: \(conversation.avatarReceiver)")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        selectedReceiverID = conversation.receiverID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatController = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
              chatController.receiverName = conversation.nameReceiver
              chatController.receiverID = conversation.receiverID
              navigationController?.pushViewController(chatController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         //return UITableView.automaticDimension
         return 100
    }
}

   //MARK: - Extension TableView
//extension MessagesVC: UITableViewDelegate, UITableViewDataSource{
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 8
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footer = UIView()
//            footer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
//        return footer
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagesTableViewCell
//        return cell
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 99
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewVC") as? ChatViewVC {
//            navigationController?.pushViewController(chatViewController, animated: true)
//          }
//      }
//  }
