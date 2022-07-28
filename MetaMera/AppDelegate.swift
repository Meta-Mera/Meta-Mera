//
//  AppDelegate.swift
//  MetaMera
//
//  Created by Jim on 2022/05/10.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //MARK: Quick Action
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        switch shortcutItem.type {
        case "SearchAction":
            
            Auth.auth().signIn(withEmail: "g019c1045@g.neec.ac.jp", password: "123456") { res, err in
                if let err = err {
                    print("ログイン情報の取得に失敗",err)
                    return
                }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Firestore.firestore().collection("Users").document(uid).getDocument { (userSnapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = userSnapshot?.data() else { return }
                    let user = User(dic: dic,uid: uid)
                    Profile.shared.loginUser = user
                    switch Profile.shared.updateProfileImage() {
                    case .success(_):
                        print("画像あるらしいよ: ",user.profileImage,"+",uid)
                        break
                    case .failure(_):
                        print("画像保存されてないよ〜: ",user.profileImage,"+",uid)
                        Profile.shared.saveImageToDevice(image: user.profileImage, fileName: uid)
                        break
                    }
                    self.window = UIWindow()
                    self.window?.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))()
                    self.window?.makeKeyAndVisible()
                }
            }
        case "debug":
            Auth.auth().signIn(withEmail: "g019c1045@g.neec.ac.jp", password: "123456") { res, err in
                if let err = err {
                    print("ログイン情報の取得に失敗",err)
                    return
                }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Firestore.firestore().collection("Users").document(uid).getDocument { (userSnapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = userSnapshot?.data() else { return }
                    let user = User(dic: dic,uid: uid)
                    Profile.shared.loginUser = user
                    switch Profile.shared.updateProfileImage() {
                    case .success(_):
                        print("画像あるらしいよ: ",user.profileImage,"+",uid)
                        break
                    case .failure(_):
                        print("画像保存されてないよ〜: ",user.profileImage,"+",uid)
                        Profile.shared.saveImageToDevice(image: user.profileImage, fileName: uid)
                        break
                    }
                    Firestore.firestore().collection("Posts").document("Uz93q4hTLBHvLUFglhxp").getDocument { (snapshot, err) in
                        if let err = err {
                            print("投稿情報の取得に失敗しました。\(err)")
                            return
                        }
                        
                        guard let dic = snapshot?.data() else { return }
                        print("投稿情報の取得に成功しました。")
                        let post = Post(dic: dic,postId: "Uz93q4hTLBHvLUFglhxp")
                        let viewController = ChatRoomController()
                        viewController.post = post
                        viewController.image = UIImage(named: "ブラックアルフォート")!
                        viewController.postId = post.postId
                        self.window?.rootViewController = UINavigationController(rootViewController: viewController)
                    }
                }
            }
        default:
            let navigationController =  UINavigationController(rootViewController: SignUpViewController())
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
        return true
    }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        
        //sleep(1)
        window = UIWindow()
        window?.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))()
        window?.makeKeyAndVisible()
        
//        window = UIWindow()
//        window?.makeKeyAndVisible()
//
//        // 2. 最初に表示する画面を設定
//        window = UIWindow()
//        window?.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "StartUpStoryboard", bundle: .main))()
//        window?.makeKeyAndVisible()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

