//
//  Profile.swift
//  MetaMera
//
//  Created by Jim on 2022/06/23.
//

import Foundation
import UIKit
import Firebase
import AVFAudio
import CoreLocation

class Profile {
    
    static let shared = Profile()
    
    //シングルトン
    var userId: String = ""
    let userRef = Firestore.firestore().collection("users")
    var nodeLocationsLatitude = [CLLocationDegrees]()
    var nodeLocationsLongitude  = [CLLocationDegrees]()
    
//    let profileViewController = ProfileViewController()
    
    func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    func updateProfileImage() -> Result<UIImage, Error> {
        let path = getFileURL(fileName: Profile.shared.userId+".jpeg").path

        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
//                profileViewController.ProfileImage.image = imageData
                return .success(imageData)
            } else {
                print("Failed to load the image.")
                return .failure(NSError(domain: "Failed to load the image.", code: 404))
            }
        } else {
            print("Image file not found.")
            return .failure(NSError(domain: "Image file not found.", code: 404))
        }

    }
    
    func getUser(userId: String) -> Void{
        let userData = userRef.document(userId)
        
        userData.getDocument{ (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                return
            }else{
                print("Document does not exist")
            }
            
        }
        
    }
    
}

extension String {
    
//    open func getUserName(_ String)
//
//    override func getUserName(_ ) -> String {
//        let userData = userRef.document(userId)
//
//        userData.getDocument{ (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//            }else{
//                print("Document does not exist")
//            }
//
//        }
//    }
}
