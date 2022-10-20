//
//  User.swift
//  MetaMera
//
//  Created by Jim on 2022/06/30.
//

import Foundation
import Firebase

class User {
    
    let userName: String
    let createAt: Timestamp
    let profileImage: String
    let tokens: [String]
    let email: String
    let log: [String]
    let reCommend:  [String]
    //ここにお気に入りのリストを書く
    //ここにアクション[“コメントした”、”いいねをした”など]を書く
    
    //    let userId: String
    
    
    let uid: String
    
    init(dic: [String: Any], uid: String) {
        self.userName = dic["userName"]  as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.tokens = dic["tokens"] as? [String] ?? []
        self.email = dic["email"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.log = dic["Log"] as? [String]  ?? []
        self.reCommend = dic["Recommend"] as? [String] ?? []
        self.uid = uid
    }
    
    func reauthenticate(email: String, password: String, completion: @escaping(Result<Bool, NSError>) -> Void){
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        user?.reauthenticate(with: credential) { reslut,err  in
          if let err = err {
              completion(.failure(NSError(domain: "アカウントの再認証に失敗しました。\(err)", code: 400)))
              
          } else {
            // User re-authenticated.
              completion(.success(true))
          }
        }
        completion(.success(false))
    }
    
    public func changeEmail(email: String, password: String){
        
        reauthenticate(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                Auth.auth().currentUser?.updateEmail(to: email) { error in
                    if let error = error {
                        print("メールアドレスの変更に失敗しました。\(error)")
                    }else {
                        Auth.auth().languageCode = "jp"
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                print("確認メールの送信に失敗しました。\(error)")
                            }else {
                                print("メールアドレスの変更に成功しました。")
                            }
                        }
                    }
                }
            case .failure(let error):
                print("\(error)")
            }
            
        }

    }
    
    public func changePassword(email: String, password: String){
        reauthenticate(email: email, password: password) { [weak self] result in
            switch result {
            case .success(_):
                Auth.auth().currentUser?.updatePassword(to: password) { error in
                    if let error = error {
                        print("パスワードの更新に失敗しました。\(error)")
                    }else {
                        Auth.auth().languageCode = "jp"
                        Auth.auth().sendPasswordReset(withEmail: email) { error in
                            if let error = error{
                                print("パスワード変更を通知するためのメールの送信に失敗しました。\(error)")
                            }else {
                                print("パスワードの変更に成功しました。")
                            }
                        }
                    }
                }
            case .failure(let error):
                print("\(error)")
            }
            
        }

    }
    
    
    public func deleteUser(uid: String, email: String, password: String){
        
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        // Prompt the user to re-provide their sign-in credentials

        user?.reauthenticate(with: credential) { reslut,err  in
          if let err = err {
              print("アカウントの再認証に失敗しました。\(err)")
            // An error happened.
          } else {
            // User re-authenticated.
              Auth.auth().currentUser?.delete{ error in
                  if let error = error {
                      print("アカウント削除に失敗しました。\(error)")
                  }else{
                      Firestore.firestore().collection("Users").document(uid).delete { err in
                          if let err = err {
                              print("Firestoreの削除に失敗しました。\(err)")
                          }
                      }
                  }
              }
          }
        }
    }
        
}
