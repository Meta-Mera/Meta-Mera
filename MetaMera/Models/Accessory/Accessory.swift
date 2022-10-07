//
//  accessory.swift
//  MetaMera
//
//  Created by Jim on 2022/10/02.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class Accessory {
    
    func randomString(length: Int) -> String{
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
            
        }
        return randomString
    }
    
    func saveToFireStorege(selectedImage: UIImage, fileName : String, folderName: String, completion: @escaping(Result<(String, UIImage), NSError>) -> Void){
        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        let storageRef = Storage.storage().reference().child(folderName).child(fileName)
        
        let metaData = FirebaseStorage.StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
            if let err = err{
                print("firestorageへの情報の保存に失敗\(err)")
                completion(.failure(NSError(domain: "firestorageへの情報の保存に失敗\(err)", code: 400)))
                return
            }
            
            print("保存に成功")
            
            storageRef.downloadURL { [weak self] (url, err) in
                if let err = err {
                    completion(.failure(NSError(domain: "firestorageからURLの取得に失敗しました。\(err)", code: 400)))
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                completion(.success((urlString,selectedImage)))
                return
                
            }
        }
    }
    
    func savePostImageToFireStorege(selectedImage: UIImage, fileName : String, completion: @escaping(Result<(String, String), NSError>) -> Void){
        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        let storageEditRef = Storage.storage().reference().child("Posts").child("edit").child(fileName)
        let storageRawRef = Storage.storage().reference().child("Posts").child("raw").child(fileName)
        
        
        let metaData = FirebaseStorage.StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageEditRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
            if let err = err{
                completion(.failure(NSError(domain: "firestorageへの情報の保存に失敗\(err)", code: 400)))
                return
            }
            
            print("EditFileに保存成功")
            
            storageEditRef.downloadURL { [weak self] (editUrl, err) in
                if let err = err {
                    completion(.failure(NSError(domain: "firestorageからEditURLの取得に失敗しました。\(err)", code: 400)))
                    return
                }
                guard let editUrlString = editUrl?.absoluteString else { return }
                storageRawRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
                    if let err = err{
                        completion(.failure(NSError(domain: "firestorageへの情報の保存に失敗\(err)", code: 400)))
                        return
                    }
                    
                    print("RawFileに保存成功")
                    
                    storageRawRef.downloadURL { [weak self] (rawUrl, err) in
                        if let err = err {
                            completion(.failure(NSError(domain: "firestorageからrawURLの取得に失敗しました。\(err)", code: 400)))
                            return
                        }
                        guard let rawUrlString = rawUrl?.absoluteString else { return }
                        
                        completion(.success((editUrlString, rawUrlString)))
                        return
                        
                        
                        
                    }
                }
                
            }
        }
    }
    
    func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
