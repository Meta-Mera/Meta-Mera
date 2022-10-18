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
    
  
    @IBOutlet weak var nextButtonImage: UIImageView!
    @IBOutlet weak var backButtonImage: UIImageView!
    
    let signUpModel = SignUpModel()
  
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eMailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        userIdTextField.delegate = self


        
      
        backButtonImage.isUserInteractionEnabled = true
        backButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTopView(_:))))
        nextButtonImage.isUserInteractionEnabled = true
        nextButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushCreateAccountButton(_:))))
        
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
    
    
  //NextButton押した時の処理
  @objc func pushCreateAccountButton(_ sender: Any) {
        self.view.endEditing(true)
        
        handleAuthToFirebase()
    }
    
  //Firebase登録処理
    private func handleAuthToFirebase(){
        HUD.show(.progress, onView: view)
        
        signUpModel.signUp(signUpItem: .init(email: eMailTextField.text, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text, userName: userIdTextField.text)) { [weak self] result in
            switch result {
                
            case .success(let user): //Sign up 成功
                
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self?.view, delay: 1) { [weak self] (_) in
                        Profile.shared.loginUser = user
                        Profile.shared.isLogin = true
                        self?.presentToARViewController()
                    }
                }
            case .failure(let error): //Sign up 失敗
                
                HUD.hide { (_) in
                    HUD.flash(.label(error.domain), delay: 1.0) { _ in
                        print(error)
                    }
                }
            }
        }
    }
    
  //問題なく登録できた際、 Main画面に遷移
    private func presentToARViewController(){
        let storyBoard = UIStoryboard(name: "ARViewController", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "ARViewController") as! ARViewController
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
  
    

    
    //BackBotton処理
    @objc func gotoTopView(_ sender: Any){
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




