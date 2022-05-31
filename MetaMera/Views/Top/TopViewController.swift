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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
