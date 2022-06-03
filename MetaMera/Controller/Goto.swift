//
//  Goto.swift
//  MetaMera
//
//  Created by Jim on 2022/06/03.
//

import Foundation
import UIKit

class Goto : UIViewController{
    
    class func Top(view: UIViewController, completion: (() -> Void)?){
        view.view.window?.rootViewController?.dismiss(animated: true, completion: completion)
    }
    
    class func SignIn(view: UIViewController){
        let vc = SignInViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        //navController.modalTransitionStyle = .partialCurl
        view.present(navController, animated: true)
    }
    
    class func SignUp(view: UIViewController){
        let vc = SignUpViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        //navController.modalTransitionStyle = .partialCurl
        view.present(navController, animated: true)
    }
    
    class func ARView(view: UIViewController){
        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            view.present(navController, animated: true)
        }
    }
}
