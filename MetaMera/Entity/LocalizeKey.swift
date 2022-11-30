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
    
    //通報
    case spam
    case fraud
    case bullying
    case sexualHarassment
    case violence
    case notLiking
    case reportReason
    case selectReportReason
    
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
    case withdrawalFromMetaMera

    case emailAddressSettingsDescription
    case changePasswordDescription
    case notificationSettingsDescription
    case contactDescription
    case withdrawalFromMetaMeraDescription
    
    
    // selfの値をローカライズして返す
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
