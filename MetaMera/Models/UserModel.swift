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
              completion(.failure(NSError(domain: "\(err.localizedDescription)", code: 501)))
              return
          } else {
            // User re-authenticated.
              completion(.success(true))
              return
          }
        }
//        completion(.failure(NSError(domain: "アカウントの再認証に失敗しました。", code: 501)))
//        return
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
                        completion(.failure(NSError(domain: LocalizeKey.emailChangeFailed.rawValue+"\(error)", code: 502)))
                        return
                    }else {
                        Auth.auth().languageCode = LocalizeKey.language.rawValue
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                completion(.failure(NSError(domain: "Failed to send confirmation email.\(error)", code: 503)))
                                return
                            }else {
                                Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid).updateData([
                                    "email": newEmail,
                                    "oldEmail": Profile.shared.loginUser.email
                                ]){ err in
                                    if let err = err {
                                        completion(.failure(NSError(domain: "[change Email] Database update failed.\(err)", code: 508)))
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
                completion(.failure(NSError(domain: "\(error)", code: 501)))
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
                        completion(.failure(NSError(domain: "\(error.localizedDescription)", code: 504)))
                        print("パスワードの更新に失敗しました。\(error)")
                        return
                    }else {
                        Auth.auth().languageCode = LocalizeKey.language.rawValue
                        Auth.auth().sendPasswordReset(withEmail: email) { error in
                            if let error = error{
                                completion(.failure(NSError(domain: "LocalizeKey.language.rawValue\(error)", code: 503)))
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
                print("\(error.localizedDescription)")
                completion(.failure(NSError(domain: LocalizeKey.ReAuthFailed.rawValue, code: 501)))
                return
            }
            
        }

    }
    
    
    public func deleteUser(email: String, password: String, completion: @escaping(Result<Bool, NSError>) -> Void){
        
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        // Prompt the user to re-provide their sign-in credentials

        user?.reauthenticate(with: credential) { reslut,err  in
          if let err = err {
              completion(.failure(NSError(domain: LocalizeKey.ReAuthFailed.rawValue, code: 501)))
              print("アカウントの再認証に失敗しました。\(err)")
              return
            // An error happened.
          } else {
              // User re-authenticated.
              let url = URL(string: "http://18.178.90.17:8000/userdelete/"+Profile.shared.loginUser.uid)
              let request = URLRequest(url: url!)
              let session = URLSession.shared
//              session.dataTask(with: request) { (data, response, error) in
//                  if error == nil, let data = data, let response = response as? HTTPURLResponse {
//                      // HTTPヘッダの取得
//                      print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
//                      // HTTPステータスコード
//                      print("statusCode: \(response.statusCode)")
//                      print(String(data: data, encoding: String.Encoding.utf8) ?? "")
//                  }
//              }.resume()
              completion(.success(true))
              return
          }
        }
    }
}
