//
//  MapActivities.swift
//  SPONENT
//
//  Created by Rao Ahmad on 18/10/2023.
//

import Foundation

// MARK: - MapActivityModel
struct  mapActivityModel: Codable {
    let code: Int
    let body: mapActivityBody
}

// MARK: - MapActivityBody
struct mapActivityBody: Codable {
    let activities: [MapActivities]
}

// MARK: - MapActivity
struct MapActivities: Codable {
    let activity, activityID, categoryID: String
    let location: String
    let catAvatar: String
    let latitude: String
    let longitude: String
    let distance: String

    enum CodingKeys: String, CodingKey {
        case activity = "activity"
        case activityID = "activity_id"
        case categoryID = "category_id"
        case location = "location"
        case catAvatar = "cat_avatar"
        case latitude = "latitude"
        case longitude = "longitude"
        case distance = "distance"
    }
}
