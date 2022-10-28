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
    
    let ban: Bool
    let limted: Int
    
    
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
        self.ban = dic["ban"] as? Bool ?? false
        self.limted = dic["limted"] as? Int ?? 0
        self.uid = uid
    }
    
    /// アカウントの再認証
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    ///   - completion: 成功すれば.success(true)失敗すれば.failure()
    func reauthenticate(email: String, password: String, completion: @escaping(Result<Bool, NSError>) -> Void){
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        user?.reauthenticate(with: credential) { reslut,err  in
          if let err = err {
              completion(.failure(NSError(domain: "アカウントの再認証に失敗しました。\(err)", code: 400)))
              return
          } else {
            // User re-authenticated.
              completion(.success(true))
              return
          }
        }
        completion(.failure(NSError(domain: "アカウントの再認証に失敗しました。", code: 400)))
        return
    }
    
    /// メールアドレス変更
    /// - Parameters:
    ///   - oldEmail: 古いメールアドレス
    ///   - newEmail: 新しいメールアドレス
    ///   - password: 現在使用しているメールアドレス(再認証に使用します。)
    public func changeEmail(oldEmail: String, newEmail: String, password: String){
        
        reauthenticate(email: oldEmail, password: password) {result in
            switch result {
            case .success(_):
                Auth.auth().currentUser?.updateEmail(to: newEmail) { error in
                    if let error = error {
                        print("メールアドレスの変更に失敗しました。\(error)")
                    }else {
                        Auth.auth().languageCode = "jp"
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                print("確認メールの送信に失敗しました。\(error)")
                            }else {
                                Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid).updateData([
                                    "email": newEmail
                                ]){ err in
                                    if let err = err {
                                        print("[change Email] Firestoreの更新に失敗しました。\(err)")
                                    }else{
                                        print("[change Email] メールアドレスの変更に成功しました。")
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("\(error)")
            }
            
        }

    }
    
    /// パスワード変更
    /// - Parameters:
    ///   - email: ログインしているメールアドレス
    ///   - oldPassword: 古いメールアドレス
    ///   - newPassword: 新しいメールアドレス
    //TODO: Firestoreに新しいメールアドレスを保存するようにすること!!
    public func changePassword(email: String, oldPassword: String, newPassword: String){
        reauthenticate(email: email, password: oldPassword) { result in
            switch result {
            case .success(_):
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
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
