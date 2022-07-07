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

        
    }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let rgba = UIColor(red: 65/255, green: 93/255, blue:90/255, alpha: 1.0)
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
                HUD.hide()
                HUD.show(.labeledError(title: "パスワードが弱いです。", subtitle: "6文字以上にして下さい。"))
                HUD.hide(afterDelay: 1.0)
            }
        }else {
            HUD.hide()
            HUD.show(.labeledError(title: "パスワードの不一致", subtitle: ""))
            HUD.hide(afterDelay: 1.0)
            
        }
    }
    
  //Firebase新規登録のテンプレート作成
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




