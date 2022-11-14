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
    let deleted: Bool
    let hidden: Bool
    
    var sendUser: User?
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.hidden = dic["hidden"] as? Bool ?? false
        self.deleted = dic["deleted"] as? Bool ?? false
        
    }
    
}


