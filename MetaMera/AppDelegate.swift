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
import FirebaseMessaging
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    
    #if DEBUG
    
    //MARK: Quick Action
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let signInModel = SignInModel()
        switch shortcutItem.type {
        case "jim":
            
            signInModel.signIn(signInItem: .init(email: "g019c1045@g.neec.ac.jp", password: "123456")) {[weak self] result in
                switch result{
                case .success(_):
                    self?.window?.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))()
                    self?.window?.makeKeyAndVisible()
                    IQKeyboardManager.shared.enable = true
                    IQKeyboardManager.shared.enableAutoToolbar = false
                case .failure(_): break
                }
            }
        case "abe":
            signInModel.signIn(signInItem: .init(email: "g019c1053@g.neec.ac.jp", password: "123456")) {[weak self] result in
                switch result{
                case .success(_):
                    self?.window?.rootViewController = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))()
                    self?.window?.makeKeyAndVisible()
                    IQKeyboardManager.shared.enable = true
                    IQKeyboardManager.shared.enableAutoToolbar = false
                case .failure(_): break
                }
            }
        default:
            let navigationController =  UINavigationController(rootViewController: SignUpViewController())
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
        return true
    }
#endif
    


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
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //MARK: Firebaseからの通知用
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
//            // [.alert, .badge, .sound]と指定されているので、「アラート、バッジ、サウンド」の3つに対しての許可をリクエストした
//            if granted {
//                // 「許可」が押された場合
//                UNUserNotificationCenter.current().delegate = self
//            } else {
//                // 「許可しない」が押された場合
//            }
//        }
        
        if #available (iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
//            self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
          }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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
    
    // クラス内の他のdelegateメソッドと同じ階層に追記
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
//
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
//                       -> Void) {
//      // If you are receiving a notification message while your app is in the background,
//      // this callback will not be fired till the user taps on the notification launching the application.
//      // TODO: Handle data of notification
//
//      // With swizzling disabled you must let Messaging know about the message, for Analytics
//      // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }
//
//      // Print full message.
//      print(userInfo)
//
//      completionHandler(UIBackgroundFetchResult.newData)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      let userInfo = notification.request.content.userInfo

      Messaging.messaging().appDidReceiveMessage(userInfo)

      // Change this to your preferred presentation option
      completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo

      Messaging.messaging().appDidReceiveMessage(userInfo)

      completionHandler()
    }

    func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      Messaging.messaging().appDidReceiveMessage(userInfo)
      completionHandler(.noData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }


}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            if #available(iOS 14.0, *) {
//                completionHandler([[.banner, .list, .sound]])
//            } else {
//                completionHandler([[.alert, .sound]])
//            }
//        }
//
//
//}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  willPresent notification: UNNotification,
//                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
//                                    -> Void) {
//        let userInfo = notification.request.content.userInfo
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // ...
//
//        // Print full message.
//        print(userInfo)
//
//        // Change this to your preferred presentation option
//        completionHandler([[.banner, .list, .sound]])
//      }
//
//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  didReceive response: UNNotificationResponse,
//                                  withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//
//        // ...
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // Print full message.
//        print(userInfo)
//
//        completionHandler()
//      }
    
}

