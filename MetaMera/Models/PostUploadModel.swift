//
//  PostUploadModel.swift
//  MetaMera
//
//  Created by Jim on 2022/09/28.
//

import Foundation
import UIKit
import Firebase

class PostUploadModel {
    
    
    func upload(postItem: PostItem, completion: @escaping(Result<Bool, NSError>) -> Void){
        
        guard let areaId = postItem.areaId,
              let genreId = postItem.genreId,
              let rawImageUrl = postItem.rawImageUrl,
              let editedImageUrl = postItem.editedImageUrl,
              let latitude = postItem.latitude,
              let longitude = postItem.longitude,
              let altitude = postItem.altitude,
              let comment = postItem.comment,
              let imageStyle = postItem.imageStyle,
              let id = postItem.id
        else {
            completion(.failure(NSError(domain: "null error", code: 400)))
            return
        }
        
        
        
        let docData = ["areaId": areaId,
                       "genreId": genreId,
                       "postUserUid": Profile.shared.loginUser.uid,
                       "rawImageUrl": rawImageUrl,
                       "editedImageUrl": editedImageUrl,
                       "good": 0,
                       "latitude": latitude,
                       "longitude": longitude,
                       "altitude": altitude,
                       "comment": comment,
                       "imageStyle": imageStyle,
                       "createdAt": Timestamp()] as [String : Any]
        
        Firestore.firestore().collection("Posts").document(id).setData(docData){ (err) in
            if let err = err {
                completion(.failure(NSError(domain: "Firestoreへの登録に失敗しました:  \(err)", code: 400)))
                return
            }
            print("登録に成功しました")
            completion(.success(true))
            return
        }
    }
    
}
