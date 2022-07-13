//
//  UITraitCollection-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/07/12.
//

import Foundation
import UIKit

extension UITraitCollection {
    
    public static var isDarkMode: Bool {
        if #available(iOS 13, *), current.userInterfaceStyle == .dark {
            return true
        }
        return false
    }
}
