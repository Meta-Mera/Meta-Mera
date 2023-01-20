//
//  WithdrawalViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit

class WithdrawalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    let userModel = UserModel()
    let inmodel = SignInModel()
    
    func withdrawal() {
        userModel.deleteUser(uid: "", email: "", password: "") {[weak self] result in
            switch result {
                
            case .success(_):
                print("アカウント削除に成功")
                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("アカウント削除に失敗しました。\(error.code)")
            }
        }
    }
    
    
    

}
