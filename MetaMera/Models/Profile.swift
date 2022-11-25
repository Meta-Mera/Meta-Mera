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
    
    
    
}
