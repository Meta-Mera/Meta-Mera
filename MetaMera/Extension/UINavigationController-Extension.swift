//
//  UINavigationController-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/12/07.
//

import Foundation
import UIKit

extension UINavigationController {
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
}
