//
//  SocketIOManager.swift
//  SPONENT
//
//  Created by StarsDev on 30/01/2024.

import Foundation
import CommonCrypto
import SocketIO
import CryptoKit

protocol SocketIOManagerDelegate: AnyObject {
    func addMessage(_ message: String, senderID: Int, receiverID: Int,time: String, mediaLink : String)
    func handleTypingEvent()
    func handleTypingDoneEvent()
    func addImages(_ imges:String, senderID: Int)
}
class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    weak var delegate: SocketIOManagerDelegate?
    let manager: SocketManager
    var socket: SocketIOClient!
    let decryptionHandler = DecryptionHandler()
    override init() {
        // Increase the connect timeout to 10 seconds
        let config = SocketIOClientConfiguration(
            arrayLiteral: .connectParams(["connect_timeout": 10000]),
            .reconnects(true),
            .reconnectAttempts(-1) // Infinite attempts
        )
        manager = SocketManager(socketURL: URL(string: "https://social.untamedoutback.com.au:3000/")!, config: config)
        super.init()
        socket = manager.defaultSocket
        setupSocketHandlers()
    }
    private func setupSocketHandlers() {
        print("Socket Status: \(self.socket.status)")
        socket.on("join") { (data, ack) in
            print("Socket Ack: \(ack)")
            print("Emitted Data: \(data)")
        }
        socket.on(clientEvent: .connect) { type, emitter in
            print("Socket Connected")
            print("Socket Status: \(self.socket.status)")
        }
        socket.on("private_message") { [weak self] (data, ack) in
            guard let self = self else { return }
            if let messageData = data.first as? [String: Any] {
                // Handle the private message data here
                self.handlePrivateMessage(data: messageData)
            }
        }
        socket.on("typing") { [weak self] (data, ack) in
            guard let self = self else { return }
            if let eventData = data.first as? [String: Any] {
                // Handle typing event with the entire eventData
                print("Received typing event with data: \(eventData)")
                self.delegate?.handleTypingEvent()
            }
        }
        // Add handler for "typing_done" event
        socket.on("typing_done") { [weak self] (data, ack) in
            guard let self = self else { return }

            if let eventData = data.first as? [String: Any]{
                print("Received typing Done event with data: \(eventData)")
                self.delegate?.handleTypingDoneEvent()
            }
        }
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("Socket Disconnected")
        }
        socket.on("error") { data, ack in
            print("Socket Error: \(data)")
        }
    }
    private func handlePrivateMessage(data: [String: Any]) {
        if let username = data["username"] as? String,
            let encryptedMessage = data["message"] as? String,
            let avatar = data["avatar"] as? String,
            let _ = data["color"] as? String,
            let receiverID = data["receiver"] as? Int,
            let senderID = data["sender"] as? Int,
            let key = data["time"] as? Int,
            let time = data["time_html"] as? String,
            let isMedia = data["isMedia"] as? Bool,
            let isRecord = data["isRecord"] as? Bool,
            let mediaLink = data["mediaLink"] as? String{
            // Decrypt the message using the decryption function
            if let decryptedMessage = DecryptionHandler.decryptionAESModeECB(messageData: encryptedMessage, key: "\(key)-00000") {
                print("Received private message from \(avatar): \(time)")
                delegate?.addMessage(decryptedMessage, senderID: senderID, receiverID: receiverID, time: time, mediaLink:mediaLink)
                delegate?.addImages(mediaLink, senderID: senderID)
//                delegate?.addMessage("\(username): " + decryptedMessage, senderID: senderID, receiverID: receiverID, time: time)
            } else {
                print("Failed to decrypt message from \(username)")
            }
        }
    }
    func joinSocket(recipientID: String, userID: String, messageID: String, completion: @escaping (Bool) -> Void) {
        guard isSocketConnected else {
            print("Socket is not connected. Waiting for connection...")
            // Set up a one-time event listener for the 'connect' event
            socket.once(clientEvent: .connect) { [weak self] data, ack in
                print("Socket connected!")
                self?.emitJoinEvent(recipientID: recipientID, userID: userID, messageID: messageID, completion: completion)
            }
            connectSocket() // Connect the socket
            return
        }
        emitJoinEvent(recipientID: recipientID, userID: userID, messageID: messageID, completion: completion)
    }
    private func emitJoinEvent(recipientID: String, userID: String, messageID: String, completion: @escaping (Bool) -> Void) {
        let eventData: [String: Any] = [
            "recipient_id": recipientID,
            "user_id": userID,
            "message_id": messageID
        ]
        socket.emit("join", eventData)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(true) // Assume success for simplicity
        }
    }
    func sendPrivateMessage(toID: String, fromID: String, username: String, message: String, color: String, isSticker: Bool, messageReplyID: String, completion: @escaping (Bool) -> Void) {
        guard isSocketConnected else {
            print("Socket Status: \(self.socket.status)")
            print("Socket is not connected. Unable to emit 'private_message' event.")
            completion(false)
            return
        }
        let messageData: [String: Any] = [
            "to_id": toID,
            "from_id": fromID,
            "username": username,
            "msg": message,
            "color": color,
            "isSticker": isSticker,
            "message_reply_id": messageReplyID
        ]
        socket.emitWithAck("private_message", messageData).timingOut(after: 0) { ackData in
            if let ackDataDict = ackData.first as? [String: Any], ackDataDict["status"] as? Int == 200 {
                // Message sent successfully
                print("Private Message Sent Successfully!")
                completion(true)
            } else {
                // Message sending failed
                print("Failed to send private message.")
                completion(false)
            }
        }
    }
    func sendPrivateMessage(withMedia toID: String, fromID: String, username: String, message: String, color: String, isSticker: Bool, messageReplyID: String, media: String, mediaFileName: String, mediaFileSize: Int, duration: Int, completion: @escaping (Bool) -> Void) {
        guard isSocketConnected else {
            print("Socket Status: \(self.socket.status)")
            print("Socket is not connected. Unable to emit 'private_message' event.")
            completion(false)
            return
        }
        let messageData: [String: Any] = [
            "to_id": toID,
            "from_id": fromID,
            "username": username,
            "msg": message,
            "color": color,
            "isSticker": isSticker,
            "message_reply_id": messageReplyID,
            "media": media,
            "mediaFileName": mediaFileName,
            "mediaFileSize": mediaFileSize,
            "duration": duration
        ]
        socket.emitWithAck("private_message", messageData).timingOut(after: 0) { ackData in
            if let ackDataDict = ackData.first as? [String: Any], ackDataDict["status"] as? Int == 200 {
                // Message sent successfully
                print("Private Message Sent Successfully!")
                completion(true)
            } else {
                // Message sending failed
                print("Failed to send private message.")
                completion(false)
            }
        }
    }
    func sendTypingEvent(recipientID: String, userID: String) {
        let eventData: [String: Any] = [
            "recipient_id": recipientID,
            "user_id": userID
        ]
        socket.emit("typing", eventData)
    }
    func sendTypingDoneEvent(recipientID: String, userID: String) {
        let eventData: [String: Any] = [
            "recipient_id": recipientID,
            "user_id": userID
        ]
        print("Sending typing_done event with data: \(eventData)")
        socket.emit("typing_done", eventData)
    }
    func connectSocket() {
        socket.connect()
    }
    func closeConnection() {
        socket.disconnect()
        print("Disconnected from Socket!")
    }
    var isSocketConnected: Bool {
        print("Socket Status: \(socket.status)")
        return socket.status == .connected
    }
}
