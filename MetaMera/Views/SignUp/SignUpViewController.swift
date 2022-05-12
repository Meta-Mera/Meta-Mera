//
//  SignUpViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/10.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eMailTextField.delegate = self
        passwordTextField.delegate = self
        userIdTextField.delegate = self

        createAccountButton.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
    
    
    
    

    @IBAction func Exit(_ sender: Any) {
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        /**Auth.auth().createUser(withEmail: email, password: passwordText) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                print("登録に失敗しました:" ,error!.localizedDescription)
                return
             }
             print("登録に成功しました", user.email!)
         }*/
    }

}

extension SignUpViewController: UITextFieldDelegate{
    
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
