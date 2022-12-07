//
//  ChangeEmailAddressViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit

class ChangeEmailAddressViewController: UIViewController {
    
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    
    
    let userModel = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
    }
    
    func configView(){
        newEmailTextField.delegate = self
        confirmEmailTextField.delegate = self
        passwordTextField.delegate = self
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
