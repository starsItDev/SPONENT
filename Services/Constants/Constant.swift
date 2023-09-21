//
//  Constant.swift
//  SPONENT
//
//  Created by StarsDev on 12/09/2023.
//

import Foundation

struct APIConstants {
    static let baseURL = "https://playwithmeapp.com/api"
    
    struct Endpoints {
        static let login = "/app/login"
        static let signup = "/app/signup"
        static let appUser = "/app/user"
        static let resetPassword = "/app/password/reset"
        static let logout = "/app/logout"
        static let tabsCount = "/app/user/tabs"
        static let updatePassword = "/app/user/password"
        static let userUpdateProfile = "/app/user/update"
        static let userReport = "/app/user/report"
        static let blockUser = "/app/user/block"
        static let userUnblock = "/app/user/unblock"
        static let friendshipAdd = "/app/friendship/add"
        static let friendshipLeave = "/app/friendship/leave"
        static let categories = "/app/categories"
    }
}

