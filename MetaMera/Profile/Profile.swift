//
//  Profile.swift
//  MetaMera
//
//  Created by Jim on 2022/06/23.
//

import Foundation
import UIKit

class Profile {
    
    var userId = ""
    let profileViewController = ProfileViewController()
    
    func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    func updateProfileImage(){
        let path = getFileURL(fileName: "userIconImage.jpg").path
        
        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
                profileViewController.ProfileImage.image = imageData
            } else {
                print("Failed to load the image.")
            }
        } else {
            print("Image file not found.")
        }
    }
}
