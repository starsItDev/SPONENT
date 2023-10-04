////
////  ConnectModel.swift
////  SPONENT
////
////  Created by Rao Ahmad on 04/10/2023.
////
//
//import Foundation
//
//// MARK: - ConnectModel
//struct ConnectModel: Codable {
//    let code: Int
//    let body: ConnectModelBody
//}
//
//// MARK: - Body
//struct ConnectModelBody: Codable {
//    let connection: [Connection]
//}
//
//// MARK: - Connection
//struct Connection: Codable {
//    let userID, title: String
//    let photoURL: String
//    let activities: String
//
//    enum CodingKeys: String, CodingKey {
//        case userID = "user_id"
//        case title
//        case photoURL = "photo_url"
//        case activities
//    }
//}



struct ConnectModel: Codable {
    let code: Int
    let body: ConnectModelBody
}

// MARK: - Body
struct ConnectModelBody: Codable {
    let connections: [Connection]
}

// MARK: - Connection
struct Connection: Codable {
    let userID, title: String
    let photoURL: String
    let activities: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case title
        case photoURL = "photo_url"
        case activities
    }
}
