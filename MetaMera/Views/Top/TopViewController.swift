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
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signInImageView: UIImageView!
    @IBOutlet weak var signUpImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        signUpImageView.isUserInteractionEnabled = true
        signUpImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignUp)))
        
        
        signInImageView.isUserInteractionEnabled = true
        signInImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignIn)))
        
        
        UIView.animate(withDuration: 1.0,
                       delay: 1.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { () in
            self.logoImageView.center.y -= 50.0
            
        }, completion: { (Bool) in
            self.logoImageView.center.y -= 50.0
            self.signInImageView.isHidden = false
            self.signUpImageView.isHidden = false
            UIView.animate(withDuration: 1.0,
                           delay: 1.0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () in
                self.logoImageView.center.y -= 50.0
                self.signInImageView.center.y -= 50.0
                self.signUpImageView.center.y -= 50.0
                
            }, completion: { (Bool) in
                
            })
        })
    }

    
    @objc func PushSignUp(_ sender: Any) {
        Goto.SignUp(view: self)
        
    }
    @objc func PushSignIn(_ sender: Any) {
        Goto.SignIn(view: self)
    }
    
}
