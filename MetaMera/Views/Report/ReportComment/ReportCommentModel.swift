//
//  ReportCommentModel.swift
//  MetaMera
//
//  Created by Jim on 2022/12/08.
//

import Foundation
import UIKit

class ReportCommentModel {
    
    let reportModel = ReportModel()
    var selectedMenuType = MenuType.spam
    
    
    func getMenu() -> [UIMenuElement]{
        var actions = [UIMenuElement]()
//        //spam
//        actions.append(UIAction(title: LocalizeKey.spam.localizedString(), image: nil, state: self.selectedMenuType == MenuType.spam ? .on : .off,handler: {[weak self] (_) in
//            self?.selectedMenuType = .spam
//            self?.reasonButton.setTitle(LocalizeKey.spam.localizedString(), for: .normal)
//            self?.configureMenuButton()
//        }))
//        //fraud
//        actions.append(UIAction(title: LocalizeKey.fraud.localizedString(), image: nil, state: self.selectedMenuType == MenuType.fraud ? .on : .off,handler: {[weak self] (_) in
//            self?.selectedMenuType = .fraud
//            self?.reasonButton.setTitle(LocalizeKey.fraud.localizedString(), for: .normal)
//            self?.configureMenuButton()
//        }))
//        //bullying
//        actions.append(UIAction(title: LocalizeKey.bullying.localizedString(), image: nil, state: self.selectedMenuType == MenuType.bullying ? .on : .off,handler: {[weak self] (_) in
//            self?.selectedMenuType = .bullying
//            self?.reasonButton.setTitle(LocalizeKey.bullying.localizedString(), for: .normal)
//            self?.configureMenuButton()
//        }))
//        //sexualHarassment
//        actions.append(UIAction(title: LocalizeKey.sexualHarassment.localizedString(), image: nil, state: self.selectedMenuType == MenuType.sexualHarassment ? .on : .off,handler: {[weak self] (_) in
//            self?.selectedMenuType = .sexualHarassment
//            self?.reasonButton.setTitle(LocalizeKey.sexualHarassment.localizedString(), for: .normal)
//            self?.configureMenuButton()
//        }))
//        //violence
//        actions.append(UIAction(title: LocalizeKey.violence.localizedString(), image: nil, state: self.selectedMenuType == MenuType.violence ? .on : .off,handler: {[weak self] (_) in
//            self?.selectedMenuType = .violence
//            self?.reasonButton.setTitle(LocalizeKey.violence.localizedString(), for: .normal)
//            self?.configureMenuButton()
//        }))
//        //notLiking
//        actions.append(UIAction(title: LocalizeKey.notLiking.localizedString(), image: nil, state: self.selectedMenuType == MenuType.notLiking ? .on : .off,handler: {[weak self] (_) in
//            self?.selectedMenuType = .notLiking
//            self?.reasonButton.setTitle(LocalizeKey.notLiking.localizedString(), for: .normal)
//            self?.configureMenuButton()
//        }))
        
        return actions
    }
    
}
