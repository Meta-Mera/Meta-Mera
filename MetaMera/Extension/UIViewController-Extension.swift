//
//  UIViewController-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/09/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    func setSwipeBack() {
        let target = self.navigationController?.value(forKey: "_cachedInteractionController")
        let recognizer = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
        self.view.addGestureRecognizer(recognizer)
    }
}
