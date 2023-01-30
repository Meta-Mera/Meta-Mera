//
//  ResetPassViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2023/01/23.
//

import UIKit
import Firebase

class ResetPassViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configView(){
        emailTextField.addBorderBottom(height: 2.5, color: UIColor.rgb(red: 87, green: 79, blue: 70))
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "example@meta-mera.com", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
    }

    @IBAction func pushSendButton(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        if email.isEmpty {
            print("不備")
            return
        }
        Auth.auth().languageCode = LocalizeKey.language.localizedString()
        Auth.auth().sendPasswordReset(withEmail: email){ error in
            if let error = error {
                print("再設定用メールアドレスの送信に失敗しました。\(error)")
                return
            }
            do {
                try Auth.auth().signOut()
                Profile.shared.isLogin = false
                let vc = MetaMera.ResetedPassViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            return
        }
    }
    

}
