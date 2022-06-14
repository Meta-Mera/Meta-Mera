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


struct User {
    
    let userId: String
    let createAt: Timestamp
    let email: String
    let Recommended: [String]
    let Log: [String]
    
    init(dic: [String: Any]) {
        self.userId = dic["userId"] as! String
        self.createAt = dic["createAt"] as! Timestamp
        self.email = dic["email"] as! String
        self.Recommended = dic["Recommended"] as! [String]
        self.Log = dic["Log"] as! [String]
    }
    
    
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUp: UILabel!
    
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var toSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eMailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        userIdTextField.delegate = self

        //createAccountButton.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createAccountButton.layer.cornerRadius = 20
        createAccountButton.isEnabled = false
        createAccountButton.backgroundColor = UIColor.rgb(red: 184, green: 186, blue: 185)
        
    }

    @objc func showKeyboard(notification: Notification){
        
        signUp.isHidden = true
        
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let stackViewMaxY = createAccountButton.frame.maxY
        //let stackViewMaxY = userIdTextField.frame.maxY - 20
        
        let distance = stackViewMaxY - keyboardMinY
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            //self.view.transform = transform
            self.stackView.transform = transform
        })
    }
    
    @objc func hideKeyboard(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            //self.view.transform = .identity
            self.stackView.transform = .identity
        })
        signUp.isHidden = false
    }
    
    
    
    

    @IBAction func Exit(_ sender: Any) {
    }
    
    
    @IBAction func pushCreateAccountButton(_ sender: Any) {
        self.view.endEditing(true)
        handleAuthToFirebase()
    }
    
    private func handleAuthToFirebase(){
        HUD.show(.progress, onView: view)
        guard let email = eMailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let confirmPassword = confirmPasswordTextField.text else { return }
        
        if password == confirmPassword {
            if(passwordTextField.text!.count >= 6){
                Auth.auth().createUser(withEmail: email, password: password) { [self] (res, err) in
                    if let err = err{
                        print("Firebaseの登録に失敗しました: \(err)" )
                        HUD.hide { (_) in
                            HUD.flash(.error, delay: 1)
                        }
                        return
                    }
                    self.addUserInfoToFirestore(email: email, profileImageName: "")
                }
            }else{
                HUD.hide { (_) in
                    HUD.flash(.labeledImage(image: PKHUDAssets.crossImage, title: "パスワードが弱いです。", subtitle: "6文字以上にして下さい。"), delay: 1)
                }
            }
        }else {
            HUD.hide { (_) in
                HUD.flash(.labeledImage(image: PKHUDAssets.crossImage, title: "パスワードの不一致", subtitle: ""), delay: 1)
            }
        }
    }
    
    private func addUserInfoToFirestore(email: String, profileImageName: String){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userId = self.userIdTextField.text  else { return }
        
        let docData = ["email": email,
                       "userId": userId,
                       "profileImage": profileImageName, //TODO: プロフィール画像を保存できるようにする
                       "Log": [String]().self,
                       "Recommended": [String]().self,
                       "createAt": Timestamp()] as [String : Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        
        userRef.setData(docData) { (err) in
            if let err = err {
                print("Firestoreへの登録に失敗しました: \(err)" )
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            print("登録に成功しました")
            
            userRef.getDocument { (snapshot, err) in
                if let err = err {
                    print("ユーザ情報の取得に失敗しました。\(err)")
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    return
                }
                
//                let data = snapshot?.data()
                
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        self.presentToARViewController()
                    }
                }
                
                
            }
        }
    }
    
    private func presentToARViewController(){
        let storyBoard = UIStoryboard(name: "ARViewController", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "ARViewController") as! ARViewController
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    @IBAction func gotoSignIn(_ sender: Any) {
        let vc = SignInViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    
    

}
    
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = eMailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let confirmPasswordIsEmpty = confirmPasswordTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty || confirmPasswordIsEmpty {
            createAccountButton.isEnabled = false
            createAccountButton.backgroundColor = UIColor.rgb(red: 184, green: 186, blue: 185)
        }else{
            createAccountButton.isEnabled = true
            createAccountButton.backgroundColor = UIColor.rgb(red: 104, green: 164, blue: 140)
        }
    }
    
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


