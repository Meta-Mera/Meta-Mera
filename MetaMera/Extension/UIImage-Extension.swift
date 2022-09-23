//
//  UIImage-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/09/12.
//

import UIKit

extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
//    public convenience init (url: URL?, defaultUIImage: UIImage? = nil){
//        if url == nil {
//            self.init()
//        }
//
//        DispatchQueue.global().async {
//            do {
//                let imageData: Data! = try Data(contentsOf: url!)
//                DispatchQueue.main.async {
//                    if let data = imageData {
//                        self.init(data: data)!
//                    } else {
//                        self.init()
//                    }
//                }
//            }
//            catch {
//                DispatchQueue.main.async {
//                    self.init()
//                }
//            }
//        }
//    }
    
    public convenience init(url: URL, defaultUIImage: UIImage? = nil) {
        DispatchQueue.main.async {

        }
        do {
                let data = try Data(contentsOf: url)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()

    }
}
