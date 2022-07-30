//
//  SignInModel.swift
//  MetaMera
//
//  Created by Jim on 2022/07/28.
//

import Foundation
import Firebase

class SignInModel {
    
    
    /// サインイン処理
    /// - Parameters:
    ///   - signItem: メアド,パスワード
    ///   - completion: 結果
    func signIn(signInItem: SignInItem, completion: @escaping(Result<Bool, Error>) -> Void){
        
        guard let email = signInItem.email,
              let password = signInItem.password else {
            completion(.failure(NSError(domain: "null error", code: 400)))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let err = err {
                completion(.failure(NSError(domain: "ログイン情報の取得に失敗\(err)", code: 400)))
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection("Users").document(uid).getDocument { (userSnapshot, err) in
                if let err = err {
                    completion(.failure(NSError(domain: "ユーザー情報の取得に失敗しました。\(err)", code: 400)))
                    return
                }
                
                guard let dic = userSnapshot?.data() else { return }
                let user = User(dic: dic,uid: uid)
                Profile.shared.loginUser = user
                switch Profile.shared.updateProfileImage() {
                case .success(_):
                    
                    //LogGet
//                    self.logGetModel.logPrint(uid: uid) { result in
//                        switch result {
//                        case .success(let res):
//                            print(res)
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
                    
                    print("画像あるらしいよ: ",user.profileImage,"+",uid)
                    break
                case .failure(_):
                    print("画像保存されてないよ〜: ",user.profileImage,"+",uid)
                    Profile.shared.saveImageToDevice(image: user.profileImage, fileName: uid)
                    break
                }
                completion(.success(true))
                return
            }
        }
        
    }
}
