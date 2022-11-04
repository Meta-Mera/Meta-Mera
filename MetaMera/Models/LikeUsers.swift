//
//  LikeUsers.swift
//  MetaMera
//
//  Created by Jim on 2022/11/04.
//

import Foundation
import Firebase

class LikeUsers {
    
    let uid: String
    let createAt: Timestamp
    
    
    init(dic: [String: Any]) {
        self.uid = dic["uid"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
    }
}
