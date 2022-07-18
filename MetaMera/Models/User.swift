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
    let email: String
    //ここにお気に入りのリストを書く
    //ここにアクション[“コメントした”、”いいねをした”など]を書く
    
//    let userId: String
    
    
    let uid: String
    
    init(dic: [String: Any], uid: String) {
        self.userName = dic["userName"]  as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.email = dic["email"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.uid = uid
    }
    
    
}
