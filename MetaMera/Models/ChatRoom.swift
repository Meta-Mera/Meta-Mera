//
//  ChatRoom.swift
//  MetaMera
//
//  Created by Jim on 2022/07/14.
//

import Foundation
import Firebase

class ChatRoom {
    
    let latestMessageId: String
    let memebers: [String]
    let createdAt: Timestamp
    
    let image: String
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.image = dic["image"] as? String ?? ""
        self.memebers = dic["memebers"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
