//
//  WithdrawalViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit
import PKHUD
import Firebase

class WithdrawalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    let userModel = UserModel()
    let inmodel = SignInModel()
    
    func withdrawal() {
        HUD.show(.progress)
        userModel.deleteUser(uid: "", email: "", password: "") {[weak self] result in
            guard let me = self else { return }
            switch result {
                
            case .success(_):
                print("アカウント削除に成功")
                HUD.hide { (_) in
                    HUD.flash(.success, onView: me.view, delay: 1) { (_) in
                        do {
                            try Auth.auth().signOut()
                            Profile.shared.isLogin = false
                            let vc = WithdrewViewController()
                            vc.modalPresentationStyle = .fullScreen
                            me.present(vc, animated: true, completion: nil)
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                }
                return
            case .failure(let error):
                HUD.hide { (_) in
                    HUD.flash(.label("アカウント削除に失敗しました。\(error.code)"), delay: 3.0) { _ in
                    }
                }
            }
        }
    }
    
    
    @IBAction func pushWithdrawal(_ sender: Any) {
        withdrawal()
    }
    
    
    

}
