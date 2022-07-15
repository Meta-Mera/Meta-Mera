//
//  Message.swift
//  MetaMera
//
//  Created by Jim on 2022/07/14.
//

import Foundation
import Firebase

class Comment {
    
    let uid: String
    let message: String
    let createdAt: Timestamp
    
    var sendUser: User?
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}

