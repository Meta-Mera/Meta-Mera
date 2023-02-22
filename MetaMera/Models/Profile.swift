//
//  Profile.swift
//  MetaMera
//
//  Created by Jim on 2022/06/23.
//

import Foundation
import UIKit
import Firebase
import AVFAudio
import CoreLocation

class Profile {
    
    static let shared = Profile()
    
    //シングルトン
    let userRef = Firestore.firestore().collection("users")
    
    //ログインユーザー
    var loginUser: User!
    //ログインしてますか？
    var isLogin: Bool!
    //エリアID
    var areaId: String!
    //ジャンルID
    var genreId: String!
    
    func authenticationStatusCheck(complition: ((Bool) -> Void)? = nil) {
        Auth.auth().addStateDidChangeListener { (_, user) in
            // ユーザー情報があるかどうかをBool値で判断する
            if user == nil {
                // 新規ユーザーの場合
                complition?(false)
                
            }else {
                // ログイン済みユーザーの場合
                complition?(true)
            }
        }
    }
    
    
    
}
