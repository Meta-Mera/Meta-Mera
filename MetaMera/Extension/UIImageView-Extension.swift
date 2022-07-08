//
//  UIImage-ExtensionView.swift
//  MetaMera
//
//  Created by Jim on 2022/07/08.
//

import Foundation
import UIKit

extension UIImageView {
    func getName() -> String? {
        return self.image?.accessibilityIdentifier
    }
}
