//
//  SignInModel.swift
//  MetaMera
//
//  Created by Jim on 2022/07/28.
//

import Foundation
import Firebase
import FirebaseMessaging

class SignInModel {
    
    
    /// サインイン処理
    /// - Parameters:
    ///   - signItem: メアド,パスワード
    ///   - completion: 結果
    func signIn(signInItem: SignInItem, completion: @escaping(Result<Bool, NSError>) -> Void){
        
        guard let email = signInItem.email,
              let password = signInItem.password else {
            completion(.failure(NSError(domain: "null error", code: 201)))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let err = err {
                let error = err.localizedDescription
                completion(.failure(NSError(domain: error, code: 204)))
                return
            }
            
            if !(Auth.auth().currentUser!.isEmailVerified){
                Auth.auth().currentUser?.sendEmailVerification()
            }
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection("Users").document(uid).getDocument { (userSnapshot, err) in
                if let err = err {
                    completion(.failure(NSError(domain: "ユーザー情報の取得に失敗しました。\(err)", code: 209)))
                    return
                }
                Messaging.messaging().token { token, error in
                    if let error = error {
                        print("error\(error)")
                    } else if let token = token {
                        guard let dic = userSnapshot?.data() else { return }
                        let user = User(dic: dic,uid: uid)
                        Profile.shared.loginUser = user
//                        var firebaseTokens = user.tokens
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
                        
                        
                        
//                        message = messaging.Message(
//                            notification=messaging.Notification(
//                                title='debug message',
//                                body='debugUserがsign inしました。',
//                            ),
//                            topic='debugUser',
//                        )
                        
                        completion(.success(true))
                        return
                    }
                }
            }
        }
        
    }
    
    func signIn(user:Firebase.User, completion: @escaping(Result<Bool, NSError>) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Users").document(uid).getDocument { (userSnapshot, err) in
            if let err = err {
                completion(.failure(NSError(domain: "ユーザー情報の取得に失敗しました。\(err)", code: 209)))
                return
            }
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("error\(error)")
                } else if let token = token {
                    guard let dic = userSnapshot?.data() else { return }
                    let user = User(dic: dic,uid: uid)
                    Profile.shared.loginUser = user
//                        var firebaseTokens = user.tokens
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
                    
                    completion(.success(true))
                    return
                }
            }
        }
    }
    
    
}
