//
//  FollowingModel.swift
//  SPONENT
//
//  Created by Rao Ahmad on 13/10/2023.
//

import Foundation

struct Model: Codable {
    let code: Int
    let body: ActivityBody
}

struct ActivityBody: Codable {
    let current, pending, rejected, followed: [Current]
    let past, extra: [Current]
}

struct Current: Codable {
    let activity, activityID, categoryID, ownerID: String
    let date, location: String
    let catAvatar: String
    let status: String?
    let distance: Int
    let ownerTitle: String
    let time: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case activity = "activity"
        case activityID = "activity_id"
        case categoryID = "category_id"
        case ownerID = "owner_id"
        case date = "date"
        case location = "location"
        case catAvatar = "cat_avatar"
        case status, distance
        case ownerTitle = "owner_title"
        case time = "time"
        case avatar = "avatar"
    }
}
