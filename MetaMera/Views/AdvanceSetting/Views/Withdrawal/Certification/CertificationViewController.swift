//
//  CertificationViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2023/01/23.
//

import UIKit
import PKHUD

class CertificationViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    func configView(){
        mailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)

        mailTextField.delegate = self
        passwordTextField.delegate = self
        
        mailTextField.attributedPlaceholder = NSAttributedString(string: "example@meta-mera.com", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderColor])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    let withdrawalModel = WithdrawalModel()
    
    @IBAction func nextButton(_ sender: Any) {
        
        guard let email = mailTextField.text,
              let password = passwordTextField.text else {return}
        
        if email.isEmpty || password.isEmpty {
            print("不備あり")
            HUD.flash(.label(LocalizeKey.incompleteEntry.localizedString()), delay: 2)
            return
        }
        
        let cancel = UIAlertAction(
            title: LocalizeKey.cancel.localizedString(),
            style: .cancel
        )
        let defaultAction = UIAlertAction(
            title: LocalizeKey.withdrawalFromMetaMera.localizedString(),
            style: .destructive) { alearAction in
                self.withdrawalModel.withdrawal(view: self, email: email, password: password)
            }
        let alert = AlartManager.shared.setting(
            title: LocalizeKey.withdrawalProcess.localizedString(),
            message: LocalizeKey.finalConfirmation.localizedString(),
            style: .alert,
            actions: [cancel,defaultAction]
        )
        self.present(alert, animated: true)
    }
    
    
    @IBAction func pushCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension CertificationViewController: UITextFieldDelegate {

    
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
