//
//  FirebaseManager.swift
//  MetaMera
//
//  Created by Jim on 2022/12/08.
//

import Foundation
import Firebase
 
enum FirebaseManager: String {
    
    // collections
    case area = "Areas"
    case genre = "Genres"
    case like = "Likes"
    case post = "Posts"
    case report = "Reports"
    case user = "Users"
    
    var ref: CollectionReference {
        let db = Firestore.firestore()
        return db.collection(self.rawValue)
    }
    
    func document(id: String) -> DocumentReference {
        return self.ref.document(id)
    }
    
    func subCollection(parentDocumentId: String, subCollection: SubCollection) -> CollectionReference {
        return self.document(id: parentDocumentId).collection(subCollection.rawValue)
    }
    
    enum SubCollection: String {
        case token = "tokens"
        case comment = "comments"
    }
}
