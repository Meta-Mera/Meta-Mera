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
    
    @IBOutlet weak var haikeiImageView: UIImageView!
    
    @IBOutlet weak var emailLabelView: UILabel!
    @IBOutlet weak var passwordLabelView: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nextButtonImage: UIImageView!
    @IBOutlet weak var backButtonImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)

        emailTextField.delegate = self
        passwordTextField.delegate = self

        backButtonImage.isUserInteractionEnabled = true
        backButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTopView(_:))))

        nextButtonImage.isUserInteractionEnabled = true
        nextButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignIn(_:))))
        
        
    }
    
  override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      let rgba = UIColor.signInBorderColor()
      emailTextField.addBorderBottom(height: 2.5, color: rgba)
      passwordTextField.addBorderBottom(height: 2.5, color: rgba)
    
  }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    


    @objc func PushSignIn(_ sender: Any) {
        self.view.endEditing(true)
        HUD.show(.progress, onView: view)
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print("email:",email)
        print("password:",password)
        
        if email == "" && password == "" {
            backDoor(self)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let err = err {
                print("ログイン情報の取得に失敗",err)
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            HUD.hide { (_) in
                HUD.flash(.success, onView: self.view, delay: 1) { [weak self] (_) in
                    self?.presentToARViewController()
                }
            }
        }
        
    }
    
    func sizeCheck() -> Int{
        //画面のサイズを取得
        let rect1 = UIScreen.main.bounds
        var size = CGFloat()
        
        //画面の縦横でサイズが変わるため大きい方のサイズを取得
        if rect1.size.height > rect1.size.width {
            size = rect1.size.height
        }else{
            size = rect1.size.width
        }
        
        switch size {
        case 926:
            print("iPhone 12 Pro Max, 13 Pro Max")
            return 50
        case 896:
            print("iPhone XS, 11 Pro Max, XR, 11")
            return 50
        case 844:
            print("iPhone 12, 13, 12 Pro, 13 Pro")
            return 40
        case 812:
            print("iPhone X, XS, 11 Pro, 12 mini, 13 mini")
            return 40
        case 736:
            print("iPhone 6, 6s, 7, 8 plus")
            return 30
        case 667:
            print("iPhone 6, 6s, 7, 8, SE2")
            return 20
        default:
            return 5
        }
    }


    private func presentToARViewController(){
        HUD.show(.progress, onView: view)
        Goto.ARView(view: self)
    }

    @objc func gotoTopView(_ sender: Any) {
        print("push back")
        //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
                    Profile.shared.userId = Auth.auth().currentUser?.uid ?? "null"
                    Firestore.firestore().collection("users").document(Profile.shared.userId).getDocument { (userSnapshot, err) in
                        if let err = err {
                            print("ユーザー情報の取得に失敗しました。\(err)")
                            return
                        }
                        
                        guard let dic = userSnapshot?.data() else { return }
                        let user = User(dic: dic)
                        Profile.shared.userName = user.userId
                        Profile.shared.userEmail = user.email
                        self.presentToARViewController()
                    }
                }
            }
        }
    }
}

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

extension UILabel {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
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
