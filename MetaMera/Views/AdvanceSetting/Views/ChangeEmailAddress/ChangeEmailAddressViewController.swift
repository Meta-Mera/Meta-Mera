//
//  ChangeEmailAddressViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit
import Firebase

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
        
        if email != confirmEmail {
            print("\(email) != \(confirmEmail)")
            return
        }
        
        userModel.changeEmail(oldEmail: Profile.shared.loginUser.email, newEmail: email, password: password) { result in
            switch result {
                
            case .success(_):
                print("メール変更に成功しました。")
                Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid).getDocument { snapshot, error in
                    if let error = error {
                        print(error)
                    }
                    guard let dic = snapshot?.data() else { return }
                    guard let uid = snapshot?.documentID else { return }
                    let user = User(dic: dic,uid: uid)
                    Profile.shared.loginUser = user
                    let vc = ChangedEmailAddressViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                return
            case .failure(let error):
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
