//
//  User.swift
//  MetaMera
//
//  Created by Jim on 2022/06/30.
//

import Foundation
import Firebase

class User {
    
    let userId: String
    let createAt: Timestamp
    let email: String
    let Recommended: [String]
    let Log: [String]
    
    init(dic: [String: Any]) {
        self.userId = dic["userId"] as! String
        self.createAt = dic["createAt"] as! Timestamp
        self.email = dic["email"] as! String
        self.Recommended = dic["Recommended"] as! [String]
        self.Log = dic["Log"] as! [String]
    }
    
    
}
