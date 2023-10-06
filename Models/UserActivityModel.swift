//
//  UserActivityModel.swift
//  SPONENT
//
//  Created by Rao Ahmad on 06/10/2023.
//

import Foundation

// MARK: - ActivityModel
struct UserActivityModel: Codable {
    let code: Int
    let body: UserActivityBody
}

// MARK: - Body
struct UserActivityBody: Codable {
    let activities: [Activities]
}

// MARK: - Activities
struct Activities: Codable {
    let activity, activityID, categoryID: String
    let ownerID, date, location: String
    let catAvatar, distance, title: String
    let time, avatar: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case activity = "activity"
        case activityID = "activity_id"
        case categoryID = "category_id"
        case ownerID = "owner_id"
        case date = "date"
        case location = "location"
        case catAvatar = "cat_avatar"
        case distance = "distance"
        case title = "owner_title"
        case time = "time"
        case avatar = "avatar"
        case status
    }
}
