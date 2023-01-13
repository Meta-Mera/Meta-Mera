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
    let oldEmail: String
    let log: [String]
    let bio: String
    let headerColor: Int
    
    let ban: Bool
    let limted: Int
    let deleted: Bool
    
    //TODO: 配信時元に戻すこと(developer)
    let developer: Bool
    
    
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
        self.oldEmail = dic["oldEmail"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.log = dic["Log"] as? [String]  ?? []
        self.reCommend = dic["Recommend"] as? [String] ?? []
        self.ban = dic["ban"] as? Bool ?? false
        self.limted = dic["limted"] as? Int ?? 0
        self.bio = dic["bio"] as? String ?? ""
        self.deleted = dic["deleted"] as? Bool ?? false
        self.headerColor = dic["headerColor"] as? Int ?? Int.random(in: 0...4)
        //TODO: 配信時元に戻すこと(developer)
        self.developer = dic["developer"] as? Bool ?? false
        self.uid = uid
    }
        
}
