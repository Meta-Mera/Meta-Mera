//
//  ReportModel.swift
//  MetaMera
//
//  Created by Jim on 2022/10/24.
//

import Foundation
import UIKit
import Firebase

class ReportModel {
    
    
    func reportPost(reportItem: ReportItem, completion: @escaping(Result<Bool, NSError>) -> Void){
        
        guard let uid = reportItem.uid,
              let comment = reportItem.comment,
              let postId = reportItem.postId,
              let reportGenre = reportItem.reportGenre
        else {
            completion(.failure(NSError(domain: "null error", code: 601)))
            return
        }
        
        let userDocData = [
            "comment": comment,
            "reportGenre": reportGenre,
            "uid": uid,
            "postId": postId,
            "createdAt": Timestamp()] as [String: Any]
        
        Firestore.firestore().collection("Reports").addDocument(data:userDocData){ err in
            if let err = err {
                print("通報データの保存に失敗しました。\(err)")
                completion(.failure(NSError(domain: "通報データの保存に失敗しました。\(err)", code: 608)))
                return
            }
            completion(.success(true))
            return
            
        }
        
        
        
        
    }
}
