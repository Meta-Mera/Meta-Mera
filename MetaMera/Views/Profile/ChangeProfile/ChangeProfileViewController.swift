//
//  ChangeProfileViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/09/12.
//

import Foundation
import UIKit
import Firebase
import Nuke
import IQKeyboardManagerSwift

class ChangeProfileViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    
    var loginUser: User!
    
    let db = Firebase.Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
//        IQKeyboardManager.shared.enable = true
    }
    
    func configView(){
        userNameLabel.text = "ユーザネームの変更"
        userNameTextField.text = loginUser.userName
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
        if let url = URL(string: loginUser.profileImage){
            Nuke.loadImage(with: url, into: userProfileImageView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        print("push back button.")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func pushUploadProfile(_ sender: Any) {
//        backButton.isEnabled = false
    }
}
