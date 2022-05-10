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

    @IBOutlet weak var SignUp: UIButton!
    @IBOutlet weak var SignIn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func PushSignUp(_ sender: Any) {
        let vc = SignUpViewController()
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true)
        
    }
    @IBAction func PushSignIn(_ sender: Any) {
        let vc = SignUpViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
}
