//
//  ChangeEmailAddressViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit
import Firebase
import PKHUD

class ChangeEmailAddressViewController: UIViewController {
    
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var nowEmailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var changeButtonLabel: UILabel!
    @IBOutlet weak var newEmailLabel: UILabel!
    @IBOutlet weak var confirmEmailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    
    let userModel = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        setUpLocalize()
    }
    
    func configView(){
        newEmailTextField.delegate = self
        confirmEmailTextField.delegate = self
        passwordTextField.delegate = self
        
        
        
    }
    
    func setUpLocalize(){
        nowEmailLabel.text = LocalizeKey.nowEmail.localizedString().replacingOccurrences(of: "%NOWEMAILL%", with: Profile.shared.loginUser.email)
        descriptionLabel.text = LocalizeKey.emailDescription.localizedString()
        changeButtonLabel.text = LocalizeKey.change.localizedString()
        
        newEmailLabel.text = LocalizeKey.newEmail.localizedString()
        confirmEmailLabel.text = LocalizeKey.confirmEmail.localizedString()
        passwordLabel.text = LocalizeKey.password.localizedString()
        titleLabel.text = LocalizeKey.changeEmailTitle.localizedString()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }


    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushNextButton(_ sender: Any) {
        guard let email = newEmailTextField.text,
              let confirmEmail = confirmEmailTextField.text,
              let password = passwordTextField.text else {
            print("null")
            return
        }
        
        if email.isEmpty || confirmEmail.isEmpty || password.isEmpty {
            HUD.flash(.label("入力不備があります。"), delay: 1.0) { _ in
            }
            return
        }
        
        if email != confirmEmail {
            HUD.flash(.label("新しいメールアドレスが一致していません。"), delay: 1.0) { _ in
            }
            return
        }
        HUD.show(.progress)
        userModel.changeEmail(oldEmail: Profile.shared.loginUser.email, newEmail: email, password: password) { result in
            switch result {
                
            case .success(_):
                print("メール変更に成功しました。")
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        do {
                            try Auth.auth().signOut()
                            Profile.shared.isLogin = false
                            let vc = ChangedEmailAddressViewController()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                }
                return
            case .failure(let error):
                HUD.hide { (_) in
                    HUD.flash(.label("メールアドレスの変更に失敗しました。\(error.code)"), delay: 3.0) { _ in
                    }
                }
                print("メール変更に失敗",error.code)
                return
            }
        }
    }
}

extension ChangeEmailAddressViewController: UITextFieldDelegate {
    
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
