//
//  ActivtyRequests.swift
//  SPONENT
//
//  Created by Rao Ahmad on 24/10/2023.
//

import Foundation

struct ActivtyRequestModel: Codable {
    let code: Int
    let body: ActivityRequestBody
}

struct ActivityRequestBody: Codable {
    let pending: [Requests]
    let accepted: [Requests]
    let rejected: [Requests]
}

struct Requests: Codable {
    let requestID, activityID, ownerID, userID: String
    let status: String?
    let userMessage: String
    let ownerMessage: ActivityJSONNull?
    let userAvatar: String
    let userName: String
    let activity: String
    let dateTime: String
    let catAvatar: String

    enum CodingKeys: String, CodingKey {
        case requestID = "request_id"
        case activityID = "activity_id"
        case ownerID = "owner_id"
        case userID = "user_id"
        case status, ownerMessage
        case userMessage = "user_message"
        case userAvatar = "user_avatar"
        case userName = "user_name"
        case activity = "activity"
        case dateTime = "date_time"
        case catAvatar = "cat_avatar"
    }
}
