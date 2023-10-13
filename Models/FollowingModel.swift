//
//  FollowingModel.swift
//  SPONENT
//
//  Created by Rao Ahmad on 13/10/2023.
//

import Foundation

// MARK: - ConnectModel
struct FollowingModel: Codable {
    let code: Int
    let body: FollowingModelBody
}

// MARK: - Body
struct FollowingModelBody: Codable {
    let connections: [Following]
    let totalItemCount: Int
}

// MARK: - Connection
struct Following: Codable {
    let userID, title: String
    let photoURL: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case title = "title"
        case photoURL = "photo_url"
    }
}
