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
        //MARK: - Login API Endpoint
        static let login = "/app/login"
        static let signup = "/app/signup"
        static let socialLogin = "/app/sociallogin"
        //MARK: - Other API Endpoint
        static let resetPassword = "/app/password/reset"
        static let logout = "/app/logout"
        static let categories = "/app/categories"
        static let appUser = "/app/user"
        static let tabsCount = "/app/user/tabs"
        static let updatePassword = "/app/user/password"
        static let userUpdateProfile = "/app/user/update"
        static let userReport = "/app/user/report"
        static let blockUser = "/app/user/block"
        static let userUnblock = "/app/user/unblock"
        static let friendshipAdd = "/app/friendship/add"
        static let friendshipLeave = "/app/friendship/leave"
        static let followers = "/app/followers"
        static let following = "/app/followings"
        static let connection = "/app/conversations"
        //MARK: Chat API Endpoint
        static let inbox = "/app/inbox"
        static let sendMessage = "/app/sendmessage"
        static let messages = "/app/messages"
        //MARK: - Activity API Endpoint
        static let getActivities = "/app/activities"
        static let createActivity = "/app/activity/create"
        static let editActivity = "/app/activity/edit"
        static let activityDetail = "/app/activity/detail"
        static let activityMine = "/app/activity/mine"
        static let joinActivity = "/app/activity/join"
        static let acceptActivity = "/app/activity/accept"
        static let rejectActivity = "/app/activity/reject"
        static let cancelActivity = "/app/activity/cancel"
        static let deleteActivity = "/app/activity/delete"
        static let deleteActivityRequest = "/app/activity/deleterequest"
        static let getActivityRequest = "/app/activity/requests"
        static let userActivities = "/app/activity/user"
        static let userActivitiesMap = "/app/activity/map"
    }
}

