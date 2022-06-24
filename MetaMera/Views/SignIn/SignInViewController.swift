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
    
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var backImageView: UIImageView!
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

        emailLabelView.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordLabelView.addBorderBottom(height: 1.0, color: UIColor.lightGray)

        backButtonImage.isUserInteractionEnabled = true
        backButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTopView(_:))))

        nextButtonImage.isUserInteractionEnabled = true
        nextButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backDoor(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification: Notification){
//        print("showKeyboard")
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue

        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let stackViewMaxY = self.textFieldView.frame.maxY + 40

        let distance = stackViewMaxY - keyboardMinY

        let transform = CGAffineTransform(translationX: 0, y: -distance)

        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { [weak self] in
            //self.view.transform = transform
            self?.textFieldView.transform = transform
            self?.backImageView.transform = transform
            self?.haikeiImageView.transform = transform
            self?.backButtonImage.isHidden = true
            self?.nextButtonImage.isHidden = true
        })
    }
    
    @objc func hideKeyboard(){
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { [weak self] in
//            self.view.transform = .identity
            self?.textFieldView.transform = .identity
            self?.backImageView.transform = .identity
            self?.haikeiImageView.transform = .identity
            self?.backButtonImage.isHidden = false
            self?.nextButtonImage.isHidden = false
        })
    }
    
    


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
                HUD.flash(.success, onView: self.view, delay: 1) { [weak self] (_) in
                    self?.presentToARViewController()
                }
            }
        }
        
    }

    private func presentToARViewController(){
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
                HUD.flash(.success, onView: self.view, delay: 1) { [weak self] (_) in
                    Profile.shared.userId = Auth.auth().currentUser?.uid ?? ""
                    self?.presentToARViewController()
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
