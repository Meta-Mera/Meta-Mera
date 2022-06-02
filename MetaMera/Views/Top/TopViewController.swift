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
    
    @IBOutlet weak var SignUpImage: UIImageView!
    @IBOutlet weak var SignInImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SignUpImage.isUserInteractionEnabled = true
        SignUpImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignUp)))
        
        
        SignInImage.isUserInteractionEnabled = true
        SignInImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignIn)))
    }

    
    @objc func PushSignUp(_ sender: Any) {
        let vc = SignUpViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        //navController.modalTransitionStyle = .partialCurl
        self.present(navController, animated: true)
        
    }
    @objc func PushSignIn(_ sender: Any) {
        let vc = SignInViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        //navController.modalTransitionStyle = .partialCurl
        self.present(navController, animated: true)
    }
    
}
