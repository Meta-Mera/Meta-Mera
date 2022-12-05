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
    
    /// ランダムな文字列を生成するやつ
    /// - Parameter length: 文字列の長さを指定
    /// - Returns: 生成した文字列が渡されるよ
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
    
    ///  UIImageをFirebase Storageに保存するよ
    /// - Parameters:
    ///   - selectedImage: 保存するUIImage
    ///   - fileName: ファイル名
    ///   - folderName: フォルダ名
    ///   - completion: 成功すれば： .success((urlString,selectedImage))でURLとUIImageが返される。
    ///   失敗すれば：.failure()でエラーが返される
    func saveToFireStorege(selectedImage: UIImage, fileName : String, folderName: String, completion: @escaping(Result<(String, UIImage), NSError>) -> Void){
        
        //画像を圧縮するよ
        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        //保存する場所をここで指定
        let storageRef = Storage.storage().reference().child(folderName).child(fileName)
        
        //メタデータを設定していく
        let metaData = FirebaseStorage.StorageMetadata()
        //ファイルの状態をjpegにする
        metaData.contentType = "image/jpeg"
        
        //Storageに保存していきます。
        storageRef.putData(uploadImage, metadata: metaData) { (metadata, err) in

            if let err = err{//保存に失敗した場合
                print("firestorageへの情報の保存に失敗\(err)")
                completion(.failure(NSError(domain: "firestorageへの情報の保存に失敗\(err)", code: 806)))
                return
            }
            //保存に成功した場合
            print("保存に成功")
            
            //保存した画像のURLをダウンロードする。
            storageRef.downloadURL {(url, err) in

                if let err = err {//URLがダウンロードできなかった場合
                    completion(.failure(NSError(domain: "firestorageからURLの取得に失敗しました。\(err)", code: 807)))
                    return
                }
                //ダウンロードできた場合
                
                //URLをString型に変更
                guard let urlString = url?.absoluteString else { return }
                
                //String型のURLを渡してあげる
                completion(.success((urlString,selectedImage)))
                return
                
            }
        }
    }
    
    /// 投稿する画像をFirebase storageに保存するよ
    /// - Parameters:
    ///   - selectedImage: 保存したい画像
    ///   - fileName: 投稿ID
    ///   - completion: 成功すれば： .success((editUrlString, rawUrlString))でURLが返ってくる
    ///   失敗すれば：.failure()でエラー内容が返ってくる
    func savePostImageToFireStorege(selectedImage: UIImage, fileName : String, completion: @escaping(Result<(String, String), NSError>) -> Void){
        //画像を圧縮する
        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        //加工用画像用
        let storageEditRef = Storage.storage().reference().child("Posts").child("edit").child(fileName)
        //生データ用
        let storageRawRef = Storage.storage().reference().child("Posts").child("raw").child(fileName)
        
        
        //メタデータを設定していく
        let metaData = FirebaseStorage.StorageMetadata()
        //jpegって教えてあげる
        metaData.contentType = "image/jpeg"
        
        //加工用画像を保存していく
        storageEditRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
            if let err = err{//保存に失敗
                completion(.failure(NSError(domain: "firestorageへ加工用画像の保存に失敗\(err)", code: 802)))
                return
            }
            //保存成功
            print("EditFileに保存成功")
            
            //URLを取得
            storageEditRef.downloadURL {(editUrl, err) in
                if let err = err {//取得に失敗
                    completion(.failure(NSError(domain: "firestorageからEditURLの取得に失敗しました。\(err)", code: 803)))
                    return
                }
                //取得に成功したからURLをString型に変更
                guard let editUrlString = editUrl?.absoluteString else { return }
                
                //生画像を保存していく
                storageRawRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
                    if let err = err{//保存に失敗
                        completion(.failure(NSError(domain: "firestorageへ生画像の保存に失敗\(err)", code: 804)))
                        return
                    }
                    //保存に成功
                    print("RawFileに保存成功")
                    
                    //URLを取得
                    storageRawRef.downloadURL { (rawUrl, err) in
                        if let err = err {//取得できなかった
                            completion(.failure(NSError(domain: "firestorageからrawURLの取得に失敗しました。\(err)", code: 805)))
                            return
                        }
                        //取得に成功したからURLをString型に変更
                        guard let rawUrlString = rawUrl?.absoluteString else { return }
                        
                        //二つのURLを渡す
                        completion(.success((editUrlString, rawUrlString)))
                        return
                        
                    }
                }
            }
        }
    }
    
    func updateProfileImageToFirestore(profileImageUrl: String){
        //        Firestore.firestore().document("users").collection(Profile.shared.userId).value(forKey: "")
        let doc = Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid)
        doc.updateData([
            "profileImage" : profileImageUrl]
        ) { err in
            if let err = err {
                print("firestoreの更新に失敗\(err)")
                return
            }
            print("更新成功")
            
        }
        
    }
    
    ///タイムスタンプを日本時間で表示するやつ
    func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
