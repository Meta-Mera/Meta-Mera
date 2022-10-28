//
//  SignUpModel.swift
//  MetaMera
//
//  Created by Jim on 2022/07/30.
//

import Foundation
import Firebase

class SignUpModel {
    
    /// 新規アカウント作成処理
    /// - Parameters:
    ///   - signUpItem: メアド,パスワード,パスワード確認,ユーザ名
    ///   - completion: 結果
    func signUp(signUpItem: SignUpItem, completion: @escaping(Result<User, NSError>) -> Void){
        
        
        
        guard let email = signUpItem.email,
              let password = signUpItem.password,
              let confirmPassword = signUpItem.confirmPassword,
              let userName = signUpItem.userName else {
            completion(.failure(NSError(domain: "null error", code: 400)))
            return
        }
        
        guard password == confirmPassword else {
            completion(.failure(NSError(domain: "パスワードの不一致", code: 400)))
            return
        }
        
        guard password.count >= 6 else {
            completion(.failure(NSError(domain: "パスワードが弱いです。", code: 400)))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err{
                let error = err.localizedDescription
                completion(.failure(NSError(domain: error, code: 400)))
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "null error", code: 400)))
                return
                
            }
            
            let docData = ["email": email,
                           "userName": userName,
                           "ban" : false,
                           "limited" : 0,
                           "profileImage": "",
                           "Log": [String]().self,
                            "Recommended": [String]().self,
                           "createAt": Timestamp()] as [String : Any]
            let userRef = Firestore.firestore().collection("Users").document(uid)
            
            
            userRef.setData(docData) { (err) in
                if let err = err {
                    completion(.failure(NSError(domain: "Firestoreへの登録に失敗しました: \(err)", code: 400)))
                    return
                }
                print("登録に成功しました")
                
                userRef.getDocument { (snapshot, err) in
                    if let err = err {
                        completion(.failure(NSError(domain: "ユーザ情報の取得に失敗しました。\(err)", code: 400)))
                        return
                    }
                    
                    guard let dic = snapshot?.data() else { return }
                    let user = User(dic: dic, uid: uid)
                    
                    Auth.auth().currentUser?.sendEmailVerification()
                    
                    
                    Messaging.messaging().token { token, error in
                        if let error = error {
                            print("error\(error)")
                        } else if let token = token {
                            Profile.shared.loginUser = user
//                            var firebaseTokens = user.tokens
                            let doc = Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid)
    //                        doc.collection("tokens").addDocument(data: [token ®: token])
                            doc.collection("tokens").document(token).setData([token:token]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                            Messaging.messaging().subscribe(toTopic: "debugUser") { error in
                              print("Subscribed to debugUser topic")
                            }
                            Messaging.messaging().subscribe(toTopic: uid) { error in
                                print("Subscribed to \(uid) topic")
                            }
                            
                            
                        }
                    }
                    
                    
                    completion(.success(user))
                    
                    
                }
            }
            
        }
    }
    
}
