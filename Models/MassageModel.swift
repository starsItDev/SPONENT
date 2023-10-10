//
//  MassageModel.swift
//  SPONENT
//
//  Created by StarsDev on 02/10/2023.
//

import Foundation

// MARK: - MessageModel
struct MessageModel: Codable {
    let code: Int
    let body: MessageModelBody
}

// MARK: - Body
struct MessageModelBody: Codable {
    let userID: String
    let userAvatar: String
    let isOwner: Int
    let conversationID, userName: String
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case userAvatar = "user_avatar"
        case isOwner = "is_owner"
        case conversationID = "conversation_id"
        case userID = "user_id"
        case userName = "user_name"
        case messages
    }
}

// MARK: - Message
struct Message: Codable {
    let messageID, body, date: String
    let isViewer: Int

    enum CodingKeys: String, CodingKey {
        case messageID = "message_id"
        case body = "body"
        case date = "date"
        case isViewer = "is_viewer"
    }
}
