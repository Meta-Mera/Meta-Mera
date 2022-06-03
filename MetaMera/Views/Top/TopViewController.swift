//
//  TopViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/10.
//

import UIKit
import ARKit
import RealityKit

class TopViewController: UIViewController {
    
    @IBOutlet weak var SignInImage: UIImageView!
    @IBOutlet weak var SignUpImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SignUpImage.isUserInteractionEnabled = true
        SignUpImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignUp)))
        
        
        SignInImage.isUserInteractionEnabled = true
        SignInImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignIn)))
    }

    
    @objc func PushSignUp(_ sender: Any) {
        Goto.SignUp(view: self)
        
    }
    @objc func PushSignIn(_ sender: Any) {
        Goto.SignIn(view: self)
    }
    
}
