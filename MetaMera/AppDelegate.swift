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
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        /** Process the quick action if the user selected one to launch the app.
//            Grab a reference to the shortcutItem to use in the scene.
//        */
//
//        if let windowScene = scene as? UIWindowScene {
//            let window = UIWindow(windowScene: windowScene)
//            // connectionOptions.shortcutItem?.typeでQuick Actionから起動したか判別可能
//            //遷移方法は適当です。typeを保存しておいて各画面側でmodal表示とかでもいいのかもしれないです。、
//            if let shortcutItem = connectionOptions.shortcutItem {
//                // Save it off for later when we become active.
//                switch shortcutItem.type {
//                case "backdoor":
//                    print("これ！！！これ！！！これ！！！これ！！！これ！！！これ！！！これ！！！")
//                    window.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "SignInViewController", bundle: .main))()
//                default:
//                    print("これこれこれこれこれこれこれこれこれこれこれこれこれこれこれ!!!!!!!!!!!!!!!!!!!!!!!!")
//                    window.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))()
//                }
//                self.window = window
//                window.makeKeyAndVisible()
//            }
//        }
//    }
//
//    func windowScene(_ windowScene: UIWindowScene,
//                     performActionFor shortcutItem: UIApplicationShortcutItem,
//                     completionHandler: @escaping (Bool) -> Void) {
//
//        let window = UIWindow(windowScene: windowScene)
//        // connectionOptions.shortcutItem?.typeでQuick Actionから起動したか判別可能
//        //遷移方法は適当です。typeを保存しておいて各画面側でmodal表示とかでもいいのかもしれないです。、
//        switch shortcutItem.type{
//        case "backdoor":
//            print("これ！！！！！！！！！")
//            window.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "SignInViewController", bundle: .main))()
//        default:
//            print("!!!!!!!!!!!!!!!!!!!!!!!!これこれこれこれこれこれこれこれこれこれこれこれこれこれこれ")
//            window.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))()
//        }
//        self.window = window
//        window.makeKeyAndVisible()
//    }
    
    
    var launchedShortcutItem: UIApplicationShortcutItem?
    func applications(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("呼ばれた1")
        // If the app is launched by Quick Action, then take the relevant action
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            print("呼ばれた2")
            
            // Since, the app launch is triggered by QuicAction, block "performActionForShortcutItem:completionHandler" method from being called.
            return false
        }
        print("呼ばれた3")
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

