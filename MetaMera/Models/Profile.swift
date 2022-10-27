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
    let userRef = Firestore.firestore().collection("users")
    
    //ログインユーザー
    var loginUser: User!
    //ログインしてますか？
    var isLogin: Bool!
    //エリアID
    var areaId: String!
    
    func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    func updateProfileImage() -> Result<UIImage, Error> {
        let path = getFileURL(fileName: Profile.shared.loginUser.uid+".jpeg").path

        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
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
    
    func convertUrlToImage(imageUrl: String) -> Result<UIImage, Error> {
        guard let url = URL(string: imageUrl) else { return .failure(NSError(domain: "Could not convert from URL to image.", code: 404))}
        guard let imageData = try? Data(contentsOf: url) else { return .failure(NSError(domain: "Could not convert from URL to image.", code: 404))}
        guard let image = UIImage(data: imageData)  else { return .failure(NSError(domain: "Could not convert from URL to image.", code: 404))}
        return .success(image)
    }
    
    func saveImageToDevice(image: UIImage, fileName: String){
        
    }
    
    func saveImageToDevice(image: String, fileName: String){
        switch convertUrlToImage(imageUrl: image){
            
        case .success(let saveImage):
            DispatchQueue.main.async() { [weak self] in
                //データをUIImage(jpg)に変換
                if let jpegImageData = saveImage.jpegData(compressionQuality: 1.0),
                   let saveDocumentPath = self?.getFileURL(fileName: fileName+".jpeg") {
                    do {
                        //端末に保存
                        try jpegImageData.write(to: saveDocumentPath)
                        print("Image saved.")
                    } catch {
                        print("Failed to save the image:", error)
                    }
                }
            }
        case .failure(let error):
            print("Failed to save the image:", error)
        }
    }
    
}
