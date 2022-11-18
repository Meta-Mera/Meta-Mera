//
//  Post.swift
//  MetaMera
//
//  Created by Jim on 2022/07/14.
//

import Foundation
import Firebase

/// 投稿画像の形
///
/// editedImageUrlの形と一致させてね
///
/// - 長方形
/// rectangle = 0
///
/// - 正方形
/// square = 1
///
/// - 円形
/// circle = 2
///
/// - ToDo: APIが実装されたらやり直すこと
/// - Author: Jim
///
enum imageStyle :Int , @unchecked Sendable{

    ///長方形
    case rectangle = 0
    
    ///正方形
    case square = 1
    
    //円形
    case circle = 2
}

class Post {
    
    let areaId: String
    let genreId: String
    let postUserUid: String
    let createdAt: Timestamp
    let rawImageUrl: String
    let editedImageUrl: String
    let good: Int
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let comment: String
    let imageStyle: Int
    let deleted: Bool
    let hidden: Bool
    
    var postId: String?
    
    init(dic: [String: Any], postId: String) {
        self.areaId = dic["areaId"] as? String ?? ""
        self.genreId = dic["genreId"] as? String ?? ""
        self.postUserUid = dic["postUserUid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.rawImageUrl = dic["rawImageUrl"] as? String ?? ""
        self.editedImageUrl = dic["editedImageUrl"] as? String ?? ""
        self.good = dic["good"] as? Int ?? 0
        self.latitude = dic["latitude"] as? Double ?? 1.0
        self.longitude = dic["longitude"] as? Double ?? 1.0
        self.altitude = dic["altitude"] as? Double ?? 1.0
        self.comment = dic["comment"] as? String ?? ""
        self.imageStyle = dic["imageStyle"] as? Int ?? 0
        self.deleted = dic["deleted"] as? Bool ?? false
        self.hidden = dic["hidden"] as? Bool ?? false
        self.postId = postId
    }
}
