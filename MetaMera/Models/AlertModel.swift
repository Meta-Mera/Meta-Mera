//
//  AlertModel.swift
//  MetaMera
//
//  Created by Jim on 2022/12/08.
//

import Foundation
import UIKit

enum AlertStyle {
    case alert
}

class AlertModel{
    
//    func alert(title: String, message: String, style: UIAlertController.Style) -> UIAlertController{
//        let
//    }
    
    func OpenSetting(title: String, message: String, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Enable photos access", style: .default) { alertAction in action
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { alertAction in
        }
        
        //アラートの下にあるボタンを追加
        alert.addAction(cancel)
        alert.addAction(ok)
        //アラートの表示
        return alert
    }
    
    
}
