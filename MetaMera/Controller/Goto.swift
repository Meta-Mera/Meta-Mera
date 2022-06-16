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
        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            view.present(navController, animated: true)
        }
        
//        print("Goto-SignIn was called.")
//        let vc = SignInViewController()
//        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .fullScreen
//        //navController.modalTransitionStyle = .partialCurl
//        view.present(navController, animated: true)
        
        
    }
    
    class func SignUp(view: UIViewController){
        print("Goto-SignUp was called.")
        let vc = SignUpViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        //navController.modalTransitionStyle = .partialCurl
        view.present(navController, animated: true)
    }
    
    class func ARView(view: UIViewController){
        print("Goto-ARView was called.")
        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            view.present(navController, animated: true)
        }
    }
    
    class func Profile(view: UIViewController){
        print("Goto-Profile was called.")
        let vc = UIStoryboard(name: "ProfileViewController", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
    
    class func ChatRoom(view: UIViewController){
        print("Goto-ChatRoom was called.")
        let vc = UIStoryboard(name: "chatRoomController", bundle: nil).instantiateViewController(withIdentifier: "chatRoomController") as! chatRoomController
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
}
