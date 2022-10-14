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
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.view.window?.layer.add(transition, forKey: kCATransition)
        
        view.view.window?.rootViewController?.dismiss(animated: false, completion: completion)
    }
    
    class func TopView(view: UIViewController){
        print("Goto-TopView was called.")
        view.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        view.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //TODO: SignInの画面に移行できるように戻すこと！！
    class func SignIn(view: UIViewController){
//        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
//            let navController = UINavigationController(rootViewController: vc)
//            navController.modalPresentationStyle = .fullScreen
//            view.present(navController, animated: true)
//        }
        
        print("Goto-SignIn was called.")
        let vc = SignInViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        view.view.window?.layer.add(transition, forKey: kCATransition)
        
        view.present(navController, animated: false,completion: nil)
        
        
    }
    
    class func SignUp(view: UIViewController){
        print("Goto-SignUp was called.")
        let vc = SignUpViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        view.view.window?.layer.add(transition, forKey: kCATransition)
        
        view.present(navController, animated: false,completion: nil)
    }
    
    class func ARView(view: UIViewController){
        print("Goto-ARView was called.")
        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            view.present(navController, animated: true)
        }
    }
    
    class func Profile(view: UIViewController, user: User){
        print("Goto-Profile was called.")
        let vc = UIStoryboard(name: "ProfileViewController", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = view as! SignOutProtocol
        vc.loginUser = user
        vc.user = user
//        view.present(vc, animated: true, completion: nil)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func UserProfile(view: UIViewController, user: User){
        print("Goto-Profile was called.")
        let vc = UIStoryboard(name: "ProfileViewController", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = view as! SignOutProtocol
        vc.loginUser = user
        vc.user = user
        view.present(vc, animated: true, completion: nil)
//        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func ChangeProfile(view: UIViewController, user: User){
        print("Goto-ChangeProfile was called.")
        let vc = UIStoryboard(name: "ChangeProfileViewController", bundle: nil).instantiateViewController(withIdentifier: "ChangeProfileViewController") as! ChangeProfileViewController
//        vc.modalPresentationStyle = .fullScreen
        vc.loginUser = user
//        view.present(vc, animated: true, completion: nil)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func ChatRoomView(view: UIViewController, image: UIImage, post: Post!){
        print("Goto-ChatRoom was called.")
        let vc = UIStoryboard(name: "ChatRoomController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomController") as! ChatRoomController
        vc.image = image
        vc.postId = post.postId!
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
//        view.present(vc, animated: true, completion: nil)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func PostView(view: UIViewController, image: UIImage, chatroomId: String){
        print("Goto-ChatRoom was called.")
        let vc = UIStoryboard(name: "PostViewController", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        vc.image = image
        vc.postId = chatroomId
        vc.modalPresentationStyle = .fullScreen
//        view.present(vc, animated: true, completion: nil)
        view.navigationController?.pushViewController(vc, animated: true)
    }

    
    class func CreateNewPost(view: UIViewController){
        print("Goto-ChatRoomCreate was called.")
        let vc = UIStoryboard(name: "CreateNewPostViewController", bundle: nil).instantiateViewController(withIdentifier: "CreateNewPostViewController") as! CreateNewPostViewController
        vc.modalPresentationStyle = .fullScreen
//        view.present(vc, animated: true, completion: nil)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func DebugView(view: UIViewController){
        print("Goto-DebugView was called.")
        let vc = UIStoryboard(name: "DebugViewController", bundle: nil).instantiateViewController(withIdentifier: "DebugViewController") as! DebugViewController
        vc.modalPresentationStyle = .fullScreen
//        view.present(vc, animated: true, completion: nil)
        view.navigationController?.pushViewController(vc, animated: true)
    }
}
