//
//  ChatVC.swift
//  SPONENT
//
//  Created by Rao Ahmad on 14/09/2023.
//

import UIKit
import MessageKit

  //MARK: - Structures
struct User: SenderType {
    var senderId: String
    var displayName: String
}
 struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

    //MARK: - Class ChatVC
class ChatVC: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate,                       MessagesDisplayDelegate {
    
    //MARK: - Variables
     let user: User = User(senderId: "user1", displayName: "Guest")
     let opponent: User = User(senderId: "user2", displayName: "John")
     var messages: [Message] = []
     var receivedMessages: [Message] = []
    
    //MARK: - Override Function
     override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
        addRandomMessages()
    }
    //MARK: - Helper Functions
    func addRandomMessages() {
        let message1 = Message(sender: user, messageId: "1", sentDate: Date(), kind: .text("Hello, how are you?"))
        let message2 = Message(sender: opponent, messageId: "2", sentDate: Date(), kind: .text("I'm good, thanks!"))
        let message3 = Message(sender: user, messageId: "3", sentDate: Date(), kind: .text("Hey"))
        let message4 = Message(sender: opponent, messageId: "4", sentDate: Date(), kind: .text("Are you up for tonight?"))
        messages.append(contentsOf: [message1, message2, message3, message4])
        receivedMessages = messages
        messagesCollectionView.reloadData()
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let senderName = message.sender.displayName
        if message.sender.senderId == user.senderId {
        return NSAttributedString(string: senderName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.blue])
        } else {
        return NSAttributedString(string: senderName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.red])
        }
    }
    var currentSender: SenderType {
           return user
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return receivedMessages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return receivedMessages.count
    }
} 

    //MARK: - Class SizeCalculator
class MessageSizeCalculator: TextMessageSizeCalculator {
    override func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        var size = super.messageContainerSize(for: message, at: indexPath)
        size.width += 100
               size.height += 40
        return size
     }
  }
