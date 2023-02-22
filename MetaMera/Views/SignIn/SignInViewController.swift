//
//  SignInViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/16.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import PKHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var backGroundImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var nextButtonImage: UIImageView!
//    @IBOutlet weak var backButtonImage: UIImageView!
    
    @IBOutlet weak var buckButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    let signInModel = SignInModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewConfig()
    }
    
    func viewConfig(){
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)

        emailTextField.delegate = self
        passwordTextField.delegate = self

        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "　example@meta-mera.com", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "　Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])

//        backButtonImage.isUserInteractionEnabled = true
//        backButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTopView(_:))))
//
//        nextButtonImage.isUserInteractionEnabled = true
//        nextButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignIn(_:))))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if Profile.shared.isLogin == false {
            emailTextField.text = ""
            passwordTextField.text = ""
            Profile.shared.isLogin = nil
        }
    }
    
  override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      let rgba = UIColor.signInBorderColor()
      emailTextField.addBorderBottom(height: 2.5, color: rgba)
      passwordTextField.addBorderBottom(height: 2.5, color: rgba)
    
  }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func pushBack(_ sender: Any) {
        print("push back")
        Goto.Top(view: self, completion: nil)
    }
    @IBAction func pushNext(_ sender: Any) {
        self.view.endEditing(true)
        HUD.show(.progress, onView: view)
        signInModel.signIn(signInItem: .init(email: emailTextField.text, password: passwordTextField.text)) { [weak self] result in
            switch result{
            case .success(_): //Sign in 成功
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self?.view, delay: 1) { (_) in
                        Profile.shared.isLogin = true
                        self?.presentToARViewController()
                    }
                }
                
            case .failure(let error): //Sign in 失敗
                HUD.hide { (_) in
                    HUD.flash(.label(error.domain), delay: 3.0) { _ in
                        print(error)
                    }
                }
            }
        }
    }
    
    


    @objc func PushSignIn(_ sender: Any) {
        
    }


    private func presentToARViewController(){
        HUD.show(.progress, onView: view)
        Goto.ARView(view: self)
        HUD.hide(afterDelay: 2.0)
    }

    @objc func gotoTopView(_ sender: Any) {
        
    }
}

extension SignInViewController: UITextFieldDelegate {

    
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
