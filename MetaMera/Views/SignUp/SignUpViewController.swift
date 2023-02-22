//
//  SignUpViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import PKHUD


class SignUpViewController: UIViewController {

//    @IBOutlet weak var signUp: UILabel!
//    @IBOutlet weak var backgroundImage: UIImageView!
    
  
  @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
//    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    

  
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eMailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        userIdTextField.delegate = self


        
        configView()

        
    }
    
    func configView(){
        eMailTextField.attributedPlaceholder = NSAttributedString(string: "   example@exsample.com", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "   Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "   Comfirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
        userIdTextField.attributedPlaceholder = NSAttributedString(string: "   User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
    }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
      let rgba = UIColor.signUpBorderColor()
    eMailTextField.addBorderBottom(height: 2.5, color: rgba)
    passwordTextField.addBorderBottom(height: 2.5, color: rgba)
    confirmPasswordTextField.addBorderBottom(height: 2.5, color: rgba)
    userIdTextField.addBorderBottom(height: 2.5, color: rgba)
  }
  
  
    //テキストフィールド外を触った時の処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        eMailTextField.text = ""
        passwordTextField.text = ""
    }

    
    


    @IBAction func Exit(_ sender: Any) {
    }
    
    @IBAction func pushNext(_ sender: Any) {
        self.view.endEditing(true)
      
      guard let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text,
            let eMail = eMailTextField.text,
            let userName = userIdTextField.text else {
          return
      }
      
      if(password.isEmpty || confirmPassword.isEmpty || eMail.isEmpty || userName.isEmpty){
          HUD.flash(.label("入力不備があります。"), delay: 1.0) { _ in
          }
          return
      }
      
      guard password == confirmPassword else {
          HUD.flash(.label("パスワードの不一致"), delay: 1.0) { _ in
          }
          return
      }
      
      guard password.count >= 6 else {
          HUD.flash(.label("パスワードが弱いです。"), delay: 1.0) { _ in
          }
          return
      }
      
      let vc = CreateAccountViewController(password: password, confirmPassword: confirmPassword, eMail: eMail, userName: userName)
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
    
    @IBAction func pushBack(_ sender: Any) {
        Goto.Top(view: self, completion: nil)
    }
    
    
    
}

    
extension SignUpViewController: UITextFieldDelegate {
    
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




