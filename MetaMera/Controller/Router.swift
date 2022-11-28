//
//  Router.swift
//  MetaMera
//
//  Created by Jim on 2022/11/27.
//

import Foundation
import UIKit

final class Router {
    // アプリの初期画面を表示するメソッド
    static func showRoot(window: UIWindow) {
        // ユーザーのログイン状態を取得する
        Profile.shared.authenticationStatusCheck { (bool) in
            // ログイン状態に応じたViewControllerを取得する
            let rootVC = UIViewController.getRoot(isLogined: bool)
            // アプリの初期画面に反映させる
            window.rootViewController = rootVC
            window.makeKeyAndVisible()
        }
    }
}
