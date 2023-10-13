//
//  FollowersModel.swift
//  SPONENT
//
//  Created by Rao Ahmad on 13/10/2023.
//

import Foundation

// MARK: - ConnectModel
struct FollowerModel: Codable {
    let code: Int
    let body: FollowerModelBody
}

// MARK: - Body
struct FollowerModelBody: Codable {
    let connections: [Follower]
    let totalItemCount: Int
}

// MARK: - Connection
struct Follower: Codable {
    let userID, title: String
    let photoURL: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case title = "title"
        case photoURL = "photo_url"
    }
}
