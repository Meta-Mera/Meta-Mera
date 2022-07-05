//
//  UIColor-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/05/19.
//

import Foundation
import UIKit


extension UIColor {
    //MARK: RGBで色を決めれられるよ
    class func rgb(red: Int, green: Int, blue: Int) -> UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }
}
