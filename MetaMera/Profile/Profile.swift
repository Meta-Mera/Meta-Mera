//
//  Profile.swift
//  MetaMera
//
//  Created by Jim on 2022/06/23.
//

import Foundation
import UIKit

class Profile {
    
    static let shared = Profile()
    
    //シングルトン
    var userId = ""
    let profileViewController = ProfileViewController()
    
    func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    func updateProfileImage() -> Result<UIImage, Error> {
        let path = getFileURL(fileName: "userIconImage.jpg").path

        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
//                profileViewController.ProfileImage.image = imageData
                return .success(imageData)
            } else {
                print("Failed to load the image.")
                return .failure(NSError(domain: "Failed to load the image.", code: 400))
            }
        } else {
            print("Image file not found.")
        }
//        return nil
    }
}
