//
//  SignItem.swift
//  MetaMera
//
//  Created by Jim on 2022/07/28.
//

import Foundation

/// Sign In Item
/// (email : メアド, password: パスワード)
struct SignInItem{
    var email: String?
    var password: String?
}

///Sign Up Item
/// (email: メアド, password: パスワード, confirmPassword: パスワード確認, userName: ユーザ名)
struct SignUpItem{
    var email: String?
    var password: String?
    var confirmPassword: String?
    var userName: String?
}
