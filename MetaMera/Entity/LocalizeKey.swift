//
//  LocalizeKey.swift
//  MetaMera
//
//  Created by Jim on 2022/10/27.
//

import Foundation

enum LocalizeKey: String {
    
    //言語
    case language
    
    //共用
    case report
    case cancel
    case change
    case password
    case incompleteEntry
    case ReAuthFailed
    
    //通報
    case spam
    case fraud
    case bullying
    case sexualHarassment
    case violence
    case notLiking
    case reportReason
    case selectReportReason
    
    //ジャンル
    case creator
    case design
    case music
    case It
    case technology
    case sports
    
    //投稿画面
    case edit
    case hide
    case show
    case delete
    
    //プロフィール画面
    case accountSetting
    case advanceSetting
    case changeYourProfile
    case signOut
    case mute
    case block
    case bio
    case deleted
    case deletedDescription
    
    //詳細設定
    case emailAddressSettings
    case changePassword
    case notificationSettings
    case contact
    case appInfo
    case withdrawalFromMetaMera

    case emailAddressSettingsDescription
    case changePasswordDescription
    case notificationSettingsDescription
    case contactDescription
    case appInfoDescription
    case withdrawalFromMetaMeraDescription
    
    //メールアドレス変更
    case nowEmail
    case emailDescription
    case newEmail
    case confirmEmail
    case changeEmailTitle
    case emailaddressesDoNotMatch
    case emailChangeFailed
    
    //パスワード変更
    case passwordCharacters
    case passwordNotMatch
    
    //退会処理
    case withdrawalProcess
    case finalConfirmation
    case withdrawalFailed
    
    //パスワードリセット
    case failedToSendEmail
    
    
    // selfの値をローカライズして返す
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
