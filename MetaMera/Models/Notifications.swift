//
//  Notification.swift
//  MetaMera
//
//  Created by Jim on 2022/08/12.
//

import Foundation
import UIKit
import UserNotifications

class Notifications {
    
    func notificationRequest(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
            if granted {
//                UNUserNotificationCenter.current().delegate = self
            }
        }
    }
    
    func notification(title: String, message: String){
        
        // MARK: 通知の中身を設定
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.body = message
        content.badge = 1
        
        // MARK: 通知をいつ発動するかを設定
        // 10秒後
        let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // MARK: 通知のリクエストを作成
        let request: UNNotificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            // エラーが存在しているかをif文で確認している
            if error != nil {
                // MARK: エラーが存在しているので、エラー内容をprintする
            } else {
                // MARK: エラーがないので、うまく通知を追加できた
            }
        }
    }
    
    func notification(title: String, subTitle: String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subTitle
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
}

//extension Notification: UNUserNotificationCenterDelegate {
//
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
//}

//extension Notification: UNUserNotificationCenterDelegate{
//
////    func isEqual(_ object: Any?) -> Bool {
////
////    }
////
////    var hash: Int {
////        0
////    }
////
////    var superclass: AnyClass? {
////        superclass
////    }
////
////    func `self`() -> Self {
////
////    }
////
////    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
////
////    }
////
////    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
////
////    }
////
////    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
////
////    }
////
////    func isProxy() -> Bool {
////
////    }
////
////    func isKind(of aClass: AnyClass) -> Bool {
////
////    }
////
////    func isMember(of aClass: AnyClass) -> Bool {
////
////    }
////
////    func conforms(to aProtocol: Protocol) -> Bool {
////
////    }
////
////    func responds(to aSelector: Selector!) -> Bool {
////
////    }
////
////    var description: String {
////        description
////    }
//
//
//
//    // フォアグラウンドの状態でプッシュ通知を受信した際に呼ばれるメソッド
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        if #available(iOS 14.0, *) {
//            completionHandler([[.banner, .list, .sound]])
//        } else {
//            completionHandler([[.alert, .sound]])
//        }
//    }
//
//    // バックグランドの状態でプッシュ通知を受信した際に呼ばれるメソッド
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        completionHandler()
//    }
//
//
//}
