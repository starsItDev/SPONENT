//
//  Inbox Model.swift
//  SPONENT
//
//  Created by StarsDev on 02/10/2023.
//

import Foundation
// MARK: - InboxModel
struct InboxModel: Codable {
    let code: Int
    let body: InboxModelBody
}

// MARK: - Body
struct InboxModelBody: Codable {
    let conversations: [Conversation]
}

// MARK: - Conversation
struct Conversation: Codable {
    let avatarReceiver: String
    let nameReceiver: String
    let receiverID, isOwner: Int
    let message, date: String

    enum CodingKeys: String, CodingKey {
        case avatarReceiver = "avatar_receiver"
        case nameReceiver = "name_receiver"
        case receiverID = "receiver_id"
        case isOwner = "is_owner"
        case message, date
    }
}
