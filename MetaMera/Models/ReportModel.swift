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
            completion(.failure(NSError(domain: "null error", code: 400)))
            return
        }
        
        let docData = ["postId": postId,
                       "count": 0,
                       "createAt": Timestamp()] as [String : Any]
        
        let userDocData = [
            "comment": comment,
            "reportGenre": reportGenre,
            "createdAt": Timestamp()] as [String: Any]
        
        Firestore.firestore().collection("Reports").whereField("postId", isEqualTo: postId).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            guard snapshot!.documents.first?.data().first?.value != nil else {
                print("通報データなし")
                
                //MARK: -まず通報された投稿を通報テーブルに追加します。
                Firestore.firestore().collection("Reports").document(postId).setData(docData){ error in
                    if let error = error {
                        completion(.failure(NSError(domain: "Firestoreへの登録に失敗しました: \(error)", code: 400)))
                        return
                    }
                    
                    //MARK: - 通報したユーザーのデータを保存します。
                    Firestore.firestore().collection("Reports").document(postId).collection("Users").document(uid).setData(userDocData){ err in
                        if let err = err {
                            print("通報データの保存に失敗しました。\(err)")
                            return
                        }
                        completion(.success(true))
                        return
                        
                    }
                    
                }
                return
            }
            //MARK: - 通報したユーザーのデータを保存します。
            Firestore.firestore().collection("Reports").document(postId).collection("Users").document(uid).setData(userDocData){ err in
                if let err = err {
                    print("通報データの保存に失敗しました。\(err)")
                    return
                }
                completion(.success(true))
                return
                
            }
        }
        
        
        
        
    }
}
