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
    @IBOutlet weak var SignInButton: UIButton!
    @IBOutlet weak var toSignUpButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nextButtonImage: UIImageView!
    @IBOutlet weak var backButtonImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButtonImage.isUserInteractionEnabled = true
        backButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTopView(_:))))
        
        nextButtonImage.isUserInteractionEnabled = true
        nextButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backDoor(_:))))
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TODO: 配布時必ずバックドアを消すこと
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    @objc func showKeyboard(notification: Notification){
//        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//
//        guard let keyboardMinY = keyboardFrame?.minY else { return }
//        let stackViewMaxY = SignInButton.frame.maxY + 40
//
//        let distance = stackViewMaxY - keyboardMinY
//
//        let transform = CGAffineTransform(translationX: 0, y: -distance)
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
//            self.view.transform = transform
//        })
//    }
    
//    @objc func hideKeyboard(){
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
//            self.view.transform = .identity
//        })
//    }
    
    


    @objc func PushSignIn(_ sender: Any) {
        self.view.endEditing(true)
        HUD.show(.progress, onView: view)
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let err = err {
                print("ログイン情報の取得に失敗",err)
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            HUD.hide { (_) in
                HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                    self.presentToARViewController()
                }
            }
        }
        
    }

    private func presentToARViewController(){
        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }

    @objc func gotoTopView(_ sender: Any) {
        print("push back")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        Goto.Top(view: self, completion: nil)
    }
    
    @objc func backDoor(_ sender: Any){
        print("push next")
        HUD.show(.progress, onView: view)
//        passwordTextField.text = "123456"
//        emailTextField.text = "g019c1045@g.neec.ac.jp"
//        SignInButton.isEnabled = true
        
        Auth.auth().signIn(withEmail: "g019c1045@g.neec.ac.jp", password: "123456") { res, err in
            if let err = err {
                print("ログイン情報の取得に失敗",err)
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            HUD.hide { (_) in
                HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                    self.presentToARViewController()
                }
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
//        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
//
//        if emailIsEmpty || passwordIsEmpty {
//            SignInButton.isEnabled = false
//            SignInButton.backgroundColor = UIColor.rgb(red: 184, green: 186, blue: 185)
//        }else{
//            SignInButton.isEnabled = true
//            SignInButton.backgroundColor = UIColor.rgb(red: 104, green: 164, blue: 140)
//        }
//    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        //今フォーカスが当たっているテキストボックスからフォーカスを外す
//        textField.resignFirstResponder()
//        //次のTag番号を持っているテキストボックスがあれば、フォーカスする
//        let nextTag = textField.tag + 1
//        if let nextTextField: UITextField = self.view.viewWithTag(nextTag) as? UITextField {
//            nextTextField.becomeFirstResponder()
//        }
//        return true
//    }
    
}
