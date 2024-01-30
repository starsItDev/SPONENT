//
//  MessageModel.swift
//  SPONENT
//
//  Created by StarsDev on 30/01/2024.
//
import UIKit
import Foundation
enum MessageType {
    case text
    case image
    case video // Add this case for video
}

class ChatMessage {
    var message: String
    var time: String
    var senderId: String
    var messageType: MessageType
    var image: UIImage?
    var videoURL: URL? // Add this property for video messages

    init(message: String, time: String, senderId: String, messageType: MessageType = .text, image: UIImage? = nil, videoURL: URL? = nil) {
        self.message = message
        self.time = time
        self.senderId = senderId
        self.messageType = messageType
        self.image = image
        self.videoURL = videoURL
    }
}
