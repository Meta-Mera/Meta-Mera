//
//  WithdrawalModel.swift
//  MetaMera
//
//  Created by Jim on 2023/01/26.
//

import Foundation
import UIKit
import PKHUD
import Firebase

class WithdrawalModel {
    
    let userModel = UserModel()
    let inmodel = SignInModel()
    
    func withdrawal(view: UIViewController, email: String, password: String) {
        HUD.show(.progress)
        userModel.deleteUser(email: email, password: password) {result in
            switch result {
                
            case .success(_):
                print("アカウント削除に成功")
                HUD.hide { (_) in
                    HUD.flash(.success, onView: view.view, delay: 1) { (_) in
                        do {
                            try Auth.auth().signOut()
                            Profile.shared.isLogin = false
                            let vc = WithdrewViewController()
                            vc.modalPresentationStyle = .fullScreen
                            view.present(vc, animated: true, completion: nil)
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                }
                return
            case .failure(let error):
                HUD.hide { (_) in
                    HUD.flash(.label(LocalizeKey.withdrawalFailed.localizedString()+"\(error.code)"), delay: 3.0) { _ in
                    }
                }
            }
        }
    }
}
