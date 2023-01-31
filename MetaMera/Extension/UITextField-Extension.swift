//
//  UITextField-Extension.swift
//  MetaMera
//
//  Created by Jim on 2023/01/26.
//

import Foundation
import UIKit

extension UITextField {
    
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height + 2.5, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    
}
