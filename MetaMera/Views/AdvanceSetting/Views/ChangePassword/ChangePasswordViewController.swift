//
//  ChangePasswordViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit

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
    
    @IBAction func pushChangePassword(_ sender: Any) {
        guard let mailAddress = mailAddressTextField.text,
              let oldPassword = oldPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            print("入力情報の取得に失敗")
            return
        }
        if mailAddress.isEmpty || oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            //TODO: 不備があることを知らせるアラートを表示
            return
        }
        
        if newPassword == confirmPassword {
            
        }
        
        userModel.changePassword(email: mailAddress,
                                 oldPassword: oldPassword,
                                 newPassword: newPassword) { result in
            switch result {
            case .success(_):
                print("パスワード変更に成功")
            case .failure(let error):
                print("パスワード変更に失敗しました。\(error.code)")
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
