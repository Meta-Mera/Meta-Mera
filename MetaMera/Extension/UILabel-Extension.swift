//
//  UILabel-Extension.swift
//  MetaMera
//
//  Created by Jim on 2023/01/26.
//

import Foundation
import UIKit

extension UILabel {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}
