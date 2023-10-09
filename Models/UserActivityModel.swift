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

// MARK: - UserActivityBody
struct UserActivityBody: Codable {
    let activities: [Activities]
    let totalItemCount: Int
}

// MARK: - Activity
struct Activities: Codable {
    let activity, activityID, categoryID, ownerID: String
    let date, location: String
    let catAvatar: String
    let status: ActivityJSONNull?
    let distance, ownerTitle, time: String
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

// MARK: - Encode/decode helpers

class ActivityJSONNull: Codable, Hashable {

    public static func == (lhs: ActivityJSONNull, rhs: ActivityJSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(ActivityJSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
