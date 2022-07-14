//
//  User.swift
//  MetaMera
//
//  Created by Jim on 2022/06/30.
//

import Foundation
import Firebase

class User {
    
    let userName: String
    let createAt: Timestamp
    let profileImage: String
    //ここにお気に入りのリストを書く
    //ここにアクション[“コメントした”、”いいねをした”など]を書く
    
//    let userId: String
    
    let email: String
    let Recommended: [String]
    let Log: [String]
    
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.userName = dic["userName"]  as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.email = dic["email"] as? String ?? ""
        self.Recommended = dic["Recommended"] as? [String] ?? [""]
        self.Log = dic["Log"] as? [String] ?? [""]
        self.profileImage = dic["profileImage"] as? String ?? ""
    }
    
    
}
