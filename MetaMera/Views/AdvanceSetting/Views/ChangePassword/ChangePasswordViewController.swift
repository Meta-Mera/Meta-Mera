//
//  ChangePasswordViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    let userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func configView(){
        mailAddressTextField.text = Profile.shared.loginUser.email
        oldPasswordTextField.text = ""
        newPasswordTextField.text = ""
        confirmPasswordTextField.text = ""
        
        mailAddressTextField.delegate = self
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushChangePassword(_ sender: Any) {
        guard let mailAddress = mailAddressTextField.text,
              let oldPassword = oldPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            print("入力情報の取得に失敗")
            return
        }
        if mailAddress.isEmpty || oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            HUD.flash(.label(LocalizeKey.incompleteEntry.localizedString()), delay: 1.0) { _ in
            }
            return
        }
        
        if newPassword.count < 8 {
            HUD.flash(.label(LocalizeKey.passwordCharacters.localizedString()), delay: 1.0) { _ in
            }
            return
        }
        
        if newPassword != confirmPassword {
            HUD.flash(.label(LocalizeKey.passwordNotMatch.localizedString()), delay: 1.0) { _ in
            }
            return
        }
        
        HUD.show(.progress)
        userModel.changePassword(email: mailAddress,
                                 oldPassword: oldPassword,
                                 newPassword: newPassword) {[weak self] result in
            
            guard let `self` = self else { return }
            
            switch result {
            case .success(_):
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        do {
                            try Auth.auth().signOut()
                            Profile.shared.isLogin = false
                            Goto.ChangedPasswordViewController(view: self)
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                }
            case .failure(let error):
                print("パスワード変更に失敗しました。\(error.code)")
                if(error.localizedDescription.contains("Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later")){
                    HUD.hide { (_) in
                        HUD.flash(.label("Access to this account has been temporarily disabled due to many failed login attempts. "), delay: 3.0) { _ in
                        }
                    }
                }else if (error.localizedDescription.contains("The password is invalid or the user does not have a password")) {
                    HUD.hide { (_) in
                        HUD.flash(.label("The password is invalid."), delay: 3.0) { _ in
                        }
                    }
                }else {
                    HUD.hide { (_) in
                        HUD.flash(.label("\(error.domain)"), delay: 3.0) { _ in
                        }
                    }
                }
            }
        }
        
    }
    
}

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //今フォーカスが当たっているテキストボックスからフォーカスを外す
        textField.resignFirstResponder()
        //次のTag番号を持っているテキストボックスがあれば、フォーカスする
        let nextTag = textField.tag + 1
        if let nextTextField: UITextField = self.view.viewWithTag(nextTag) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
