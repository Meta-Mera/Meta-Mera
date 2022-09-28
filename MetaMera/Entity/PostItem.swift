//
//  PostItem.swift
//  MetaMera
//
//  Created by Jim on 2022/09/28.
//

import Foundation
import Firebase

struct PostItem{
    
    var areaId : String?
    var genreId : String?
    var postUserUid : String?
    var createdAt: Timestamp?
    var rawImageUrl : String?
    var editedImageUrl : String?
    var good : Double?
    var latitude : Double?
    var longitude : Double?
    var altitude : Double?
    var comment : String?
    
}
