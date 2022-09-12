//
//  ChangeProfileViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/09/12.
//

import Foundation
import UIKit
import Firebase

class ChangeProfileViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var loginUser: User!
    
    let db = Firebase.Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    func configView(){
        userNameLabel.text = loginUser.userName
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        print("push back image")
        self.dismiss(animated: true, completion: nil)
    }
}
