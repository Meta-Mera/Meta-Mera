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
    
    class func Back(){
        
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
    
    class func Profile(view: UIViewController){
        print("Goto-Profile was called.")
        let vc = UIStoryboard(name: "ProfileViewController", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
    
    class func ChatRoomView(view: UIViewController, image: UIImage, chatroomId: String){
        print("Goto-ChatRoom was called.")
        let vc = UIStoryboard(name: "ChatRoomController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomController") as! ChatRoomController
        vc.image = image
        vc.chatroomId = chatroomId
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
    
    class func ChatRoomJoin(view: UIViewController){
        print("Goto-ChatRoomJoin was called.")
        let vc = UIStoryboard(name: "ChatRoomJoinController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomJoinController") as! ChatRoomJoinController
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
    
    class func ChatRoomCreate(view: UIViewController){
        print("Goto-ChatRoomCreate was called.")
        let vc = UIStoryboard(name: "ChatRoomCreateController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomCreateController") as! ChatRoomCreateController
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
    
    class func CreateNewPost(view: UIViewController){
        print("Goto-ChatRoomCreate was called.")
        let vc = UIStoryboard(name: "CreateNewPostViewController", bundle: nil).instantiateViewController(withIdentifier: "CreateNewPostViewController") as! CreateNewPostViewController
        vc.modalPresentationStyle = .fullScreen
        view.present(vc, animated: true, completion: nil)
    }
}
