//
//  UIViewController-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/11/27.
//

import Foundation
import UIKit

extension UIViewController {
    // Bool値に応じてViewControllerを返すメソッド
    static func getRoot(isLogined: Bool) -> UIViewController {
        // ログイン済みユーザーの場合
        if isLogined {
            let mainVC = ARViewController()
            return mainVC

        // 新規ユーザーの場合
        }else {
            let registerVC = TopViewController()
            return registerVC
        }
    }
}
