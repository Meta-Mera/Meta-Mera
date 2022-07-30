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
    @IBOutlet weak var nextButtonImage: UIImageView!
    @IBOutlet weak var backButtonImage: UIImageView!
    
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    


    @objc func PushSignIn(_ sender: Any) {
        self.view.endEditing(true)
        HUD.show(.progress, onView: view)
        signInModel.signIn(signInItem: .init(email: emailTextField.text, password: passwordTextField.text)) { [weak self] result in
            switch result{
            case .success(_):
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self?.view, delay: 1) { (_) in
                        self?.presentToARViewController()
                    }
                }
                
            case .failure(let error):
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                    print(error)
                }
            }
        }
    }


    private func presentToARViewController(){
        HUD.show(.progress, onView: view)
        Goto.ARView(view: self)
    }

    @objc func gotoTopView(_ sender: Any) {
        print("push back")
        Goto.Top(view: self, completion: nil)
    }
}

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height + 2.5, width: self.frame.width, height: height)
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
