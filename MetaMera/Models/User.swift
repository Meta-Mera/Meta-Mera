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
    let tokens: [String]
    let email: String
    let log: [String]
    let reCommend:  [String]
    //ここにお気に入りのリストを書く
    //ここにアクション[“コメントした”、”いいねをした”など]を書く
    
//    let userId: String
    
    
    let uid: String
    
    init(dic: [String: Any], uid: String) {
        self.userName = dic["userName"]  as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.tokens = dic["tokens"] as? [String] ?? []
        self.email = dic["email"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.log = dic["Log"] as? [String]  ?? []
        self.reCommend = dic["Recommend"] as? [String] ?? []
        self.uid = uid
    }
    
    
}
