//
//  Post.swift
//  MetaMera
//
//  Created by Jim on 2022/07/14.
//

import Foundation
import Firebase

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
    
    var postId: String?
    
    init(dic: [String: Any]) {
        self.areaId = dic["areaId"] as? String ?? ""
        self.genreId = dic["genreId"] as? String ?? ""
        self.postUserUid = dic["postUserUid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.rawImageUrl = dic["rawImageUrl"] as? String ?? ""
        self.editedImageUrl = dic["editedImageUrl"] as? String ?? ""
        self.good = dic["good"] as? Int ?? 1
        self.latitude = dic["latitude"] as? Double ?? 1.0
        self.longitude = dic["longitude"] as? Double ?? 1.0
        self.altitude = dic["altitude"] as? Double ?? 1.0
    }
}
