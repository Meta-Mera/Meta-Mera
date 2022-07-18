//
//  UIImage-ExtensionView.swift
//  MetaMera
//
//  Created by Jim on 2022/07/08.
//

import Foundation
import UIKit
import Nuke

extension UIImageView {
    func getName() -> String? {
        return self.image?.accessibilityIdentifier ?? "nil"
    }
    
    func setName(_ name: String) {
        self.image?.accessibilityIdentifier = name
    }
    
    func setImage(image: UIImage, name: String){
        self.image = image
        self.image?.accessibilityIdentifier = name
        
    }
    
    func setImage(url: String, name: String){
        if let url = URL(string: url){
            Nuke.loadImage(with: url, into: self)
            self.image?.accessibilityIdentifier = name
        }
    }
}
