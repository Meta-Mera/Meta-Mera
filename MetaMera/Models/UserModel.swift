//
//  UserModel.swift
//  MetaMera
//
//  Created by Jim on 2022/11/30.
//

import Foundation
import Firebase

class UserModel {
    
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
              completion(.failure(NSError(domain: "アカウントの再認証に失敗しました。\(err)", code: 501)))
              return
          } else {
            // User re-authenticated.
              completion(.success(true))
              return
          }
        }
        completion(.failure(NSError(domain: "アカウントの再認証に失敗しました。", code: 501)))
        return
    }
    
    /// メールアドレス変更
    /// - Parameters:
    ///   - oldEmail: 古いメールアドレス
    ///   - newEmail: 新しいメールアドレス
    ///   - password: 現在使用しているメールアドレス(再認証に使用します。)
    public func changeEmail(oldEmail: String, newEmail: String, password: String, completion: @escaping(Result<Bool, NSError>) -> Void){
        
        reauthenticate(email: oldEmail, password: password) {result in
            switch result {
            case .success(_):
                Auth.auth().currentUser?.updateEmail(to: newEmail) { error in
                    if let error = error {
                        completion(.failure(NSError(domain: "メールアドレスの変更に失敗しました。\(error)", code: 502)))
                        return
                    }else {
                        Auth.auth().languageCode = "jp"
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                completion(.failure(NSError(domain: "確認メールの送信に失敗しました。\(error)", code: 503)))
                                return
                            }else {
                                Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid).updateData([
                                    "email": newEmail,
                                    "oldEmail": Profile.shared.loginUser.email
                                ]){ err in
                                    if let err = err {
                                        completion(.failure(NSError(domain: "[change Email] Firestoreの更新に失敗しました。\(err)", code: 508)))
                                        return
                                    }else{
                                        completion(.success(true))
                                        print("[change Email] メールアドレスの変更に成功しました。")
                                        return
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("\(error)")
                completion(.failure(NSError(domain: "再認証に失敗しました。", code: 501)))
                return
            }
            
        }

    }
    
    /// パスワード変更
    /// - Parameters:
    ///   - email: ログインしているメールアドレス
    ///   - oldPassword: 古いメールアドレス
    ///   - newPassword: 新しいパスワード
    //TODO: Firestoreに新しいメールアドレスを保存するようにすること!!
    public func changePassword(email: String, oldPassword: String, newPassword: String, completion: @escaping(Result<Bool, NSError>) -> Void){
        reauthenticate(email: email, password: oldPassword) { result in
            switch result {
            case .success(_):
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        completion(.failure(NSError(domain: "パスワードの更新に失敗しました。\(error)", code: 504)))
                        print("パスワードの更新に失敗しました。\(error)")
                        return
                    }else {
                        Auth.auth().languageCode = "jp"
                        Auth.auth().sendPasswordReset(withEmail: email) { error in
                            if let error = error{
                                completion(.failure(NSError(domain: "確認メールの送信に失敗しました。\(error)", code: 503)))
                                print("パスワード変更を通知するためのメールの送信に失敗しました。\(error)")
                                return
                            }else {
                                completion(.success(true))
                                print("パスワードの変更に成功しました。")
                                return
                            }
                        }
                    }
                }
            case .failure(let error):
                print("\(error)")
                completion(.failure(NSError(domain: "再認証に失敗しました。", code: 501)))
                return
            }
            
        }

    }
    
    
    public func deleteUser(uid: String, email: String, password: String, completion: @escaping(Result<Bool, NSError>) -> Void){
        
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        // Prompt the user to re-provide their sign-in credentials

        user?.reauthenticate(with: credential) { reslut,err  in
          if let err = err {
              completion(.failure(NSError(domain: "再認証に失敗しました。", code: 501)))
              print("アカウントの再認証に失敗しました。\(err)")
              return
            // An error happened.
          } else {
            // User re-authenticated.
              Auth.auth().currentUser?.delete{ error in
                  if let error = error {
                      print("アカウント削除に失敗しました。\(error)")
                      completion(.failure(NSError(domain: "アカウント削除に失敗しました。\(error)", code: 505)))
                      return
                  }else{//TODO: 多分サブコレクションとか消えてくれないよ
                      Firestore.firestore().collection("Users").document(uid).delete { err in
                          if let err = err {
                              print("Firestoreの削除に失敗しました。\(err)")
                              completion(.failure(NSError(domain: "Firestoreの削除に失敗しました。\(err)", code: 500)))
                              return
                          }
                      }
                  }
              }
          }
        }
    }
}
