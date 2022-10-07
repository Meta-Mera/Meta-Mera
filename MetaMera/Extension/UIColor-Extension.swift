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
//    let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
//       if traitCollection.userInterfaceStyle == .dark {
//           return .black
//       } else {
//           return .white
//       }
//   }
    
    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
        }
        return light
    }
    
    /// 背景色
    public static var background: UIColor {
        return dynamicColor(
            light: .white,
            dark: .black
        )
    }
    
    public static var chatRoomBackground: UIColor {
        return dynamicColor(
            light: .rgb(red: 255, green: 255, blue: 255),
            dark: .rgb(red: 0, green: 0, blue: 0)
        )
    }
    
    public static var inputChatTextBackground: UIColor {
        return dynamicColor(
            light: .rgb(red: 255, green: 255, blue: 255),
            dark: .rgb(red: 40, green: 40, blue: 40)
        )
    }
    
    public static var chatTextBackground: UIColor {
        return dynamicColor(
            light: .rgb(red: 255, green: 255, blue: 255),
            dark: .rgb(red: 0, green: 0, blue: 0)
        )
    }
    
    public static var chatText: UIColor {
        return dynamicColor(
            light: .rgb(red: 0, green: 0, blue: 0),
            dark: .rgb(red: 255, green: 255, blue: 255)
        )
    }
    
    class func signInBorderColor() -> UIColor {
        return UIColor.rgb(red: 93, green: 69, blue: 65)
    }
    
    class func signUpBorderColor() -> UIColor {
        return UIColor.rgb(red: 65, green: 93, blue: 90)
    }
}
