//
//  UIImage-ExtensionView.swift
//  MetaMera
//
//  Created by Jim on 2022/07/08.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire

extension UIImageView {

    //UIImageのaccessibilityIdentifierを取得
    func getName() -> String? {
        return self.image?.accessibilityIdentifier ?? "nil"
    }
    
    //UIImageにaccessibilityIdentifierを設定
    func setName(_ name: String) {
        self.image?.accessibilityIdentifier = name
    }
    
    //UIImageにimageとaccessibilityIdentifierを設定
    func setImage(image: UIImage, name: String){
        self.image = image
        self.image?.accessibilityIdentifier = name
        
    }
    
    //URLから取得したUIImageを設定
    func loadImageAsynchronously(url: URL?, defaultUIImage: UIImage? = nil) -> Void {
        
        if url == nil {
            self.image = defaultUIImage
            return
        }
        
        DispatchQueue.global().async {
            do {
                let imageData: Data? = try Data(contentsOf: url!)
                DispatchQueue.main.async {
                    if let data = imageData {
                        self.image = UIImage(data: data)
                    } else {
                        self.image = defaultUIImage
                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.image = defaultUIImage
                }
            }
        }
    }
}
