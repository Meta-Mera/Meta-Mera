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
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    
  
    @IBOutlet weak var nextButtonImage: UIImageView!
    @IBOutlet weak var backButtonImage: UIImageView!
  
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eMailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        userIdTextField.delegate = self

        
//        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        eMailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        confirmPasswordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        userIdTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
      
        backButtonImage.isUserInteractionEnabled = true
        backButtonImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoTopView(_:))))
    }
    
    //テキストフィールド外を触った時の処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

  
//    //キーボードを起動した時の処理
//    @objc func showKeyboard(notification: Notification){
//
//        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//
//        guard let keyboardMinY = keyboardFrame?.minY else { return }
//        let stackViewMaxY = backgroundImage.frame.maxY
//        let distance = stackViewMaxY - keyboardMinY
//        let transform = CGAffineTransform(translationX: 0, y: -distance)
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { [weak self] in
//            self?.backgroundImage.transform = transform
//        })
//    }
//
//  //キーボードが隠れた時の処理
//    @objc func hideKeyboard(){
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { [weak self] in
//            self?.backgroundImage.transform = .identity
//        })
//    }
    
    
    
    

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
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] (res, err) in
                    if let err = err{
                        print("Firebaseの登録に失敗しました: \(err)" )
                        HUD.hide { (_) in
                            HUD.flash(.error, delay: 1)
                        }
                        return
                    }
                    self?.addUserInfoToFirestore(email: email, profileImageName: "")
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
                    HUD.flash(.success, onView: self.view, delay: 1) { [weak self] (_) in
                        self?.presentToARViewController()
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
  
  
    

    
    //BackBotton処理
    @objc func gotoTopView(_ sender: Any){
        Goto.Top(view: self, completion: nil)
    }
    
    
    

}
    
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = eMailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let confirmPasswordIsEmpty = confirmPasswordTextField.text?.isEmpty ?? true
        
      
      //TryCatchに後で変更
      //nextBottonを押した後の処理
        if emailIsEmpty || passwordIsEmpty || confirmPasswordIsEmpty {
              //イレギュラー発生処理
          
        }else{
              //正常処理
              
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


