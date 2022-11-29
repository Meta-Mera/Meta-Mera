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
    
    class func SignIn(view: UIViewController){
        
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
    
    class func ProfileViewController(view: UIViewController, user: User){
        print("Goto-Profile was called.")
        let vc = MetaMera.ProfileViewController(user: user, itsMe: Profile.shared.loginUser.uid == user.uid)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func ChatRoomView(view: UIViewController, image: URL, post: Post!){
        print("Goto-ChatRoom was called.")
        let vc = UIStoryboard(name: "ChatRoomController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomController") as! ChatRoomController
        vc.imageUrl = image
        vc.postId = post.postId!
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
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
    
    class func ReportViewController(view: UIViewController, postId: String){
        print("Goto-ReportView was called.")
        let vc = UIStoryboard(name: "ReportViewController", bundle: nil).instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        vc.modalPresentationStyle = .fullScreen
        vc.postId = postId
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func EditProfileViewController(user: User, view: UIViewController){
        print("Goto-EditProfileViewController was called.")
        let vc = MetaMera.EditProfileViewController(user: user)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - 詳細設定
    
    class func AdvanceSettingViewController(view: UIViewController){
        print("Goto-AdvanceSettingViewController was called.")
        let vc = MetaMera.AdvanceSettingViewController()
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func ChangeEmailAddressViewController(view: UIViewController){
        print("Goto-ChangeEmailAddressViewController was called.")
        let vc = MetaMera.ChangeEmailAddressViewController()
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func ChangePasswordViewController(view: UIViewController){
        print("Goto-ChangePasswordViewController was called.")
        let vc = MetaMera.ChangePasswordViewController()
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func ContactViewController(view: UIViewController){
        print("Goto-ContactViewController was called.")
        let vc = MetaMera.ContactViewController()
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func NotificationViewController(view: UIViewController){
        print("Goto-NotificationViewController was called.")
        let vc = MetaMera.NotificationViewController()
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func WithdrawalViewController(view: UIViewController){
        print("Goto-WithdrawalViewController was called.")
        let vc = MetaMera.WithdrawalViewController()
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: 詳細設定 -
    
    
}
