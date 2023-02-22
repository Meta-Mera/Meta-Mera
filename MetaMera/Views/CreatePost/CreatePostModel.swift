//
//  CreatePostModel.swift
//  MetaMera
//
//  Created by Jim on 2022/12/15.
//

import Foundation
import CoreLocation
import UIKit
import PKHUD
import Firebase

class CreatePostModel {
    
    var PhotoSelected = false
    var LocationIsSet = false
    
    let postUploadModel = PostUploadModel()
    let accessory = Accessory()
    
    //MARK: 投稿情報
    var postLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var altitude: Double = 0
    var comment: String = ""
    var genreId : String = "general"
    var postImage = UIImage()
    
    func postCheck() -> Bool{
        if PhotoSelected && LocationIsSet {
            return true
        }
        return false
    }
    
    func postUpload(view: UIViewController){
        if postCheck(){
            HUD.show(.progress, onView: view.view)
            let timestamp = Timestamp()
            let time = dateFormatterForDateLabel(date: timestamp.dateValue())
            
            let fileName = time + accessory.randomString(length: 20)
            
            
            accessory.savePostImageToFireStorege(selectedImage: postImage, fileName: fileName) {[weak self] result in
                switch result {
                    
                case .success((let rawUrl, let editedUrl)):
                    self?.postUploadModel.upload(postItem: .init(
                        areaId: Profile.shared.areaId,
                        genreId: self?.genreId,
                        rawImageUrl: rawUrl,
                        editedImageUrl: editedUrl,
                        latitude: self?.postLocation.latitude,
                        longitude: self?.postLocation.longitude,
                        altitude: self?.altitude,
                        comment: self?.comment,
                        imageStyle: 3,
                        id: fileName
                    )) {result in
                        switch result {
                        case .success(_):
                            HUD.hide { (_) in
                                HUD.flash(.success, onView: view.view, delay: 1) { (_) in
                                    print("投稿成功")
                                    let url = URL(string: "http://18.178.90.17:8000/imgedit/"+fileName)
                                    let request = URLRequest(url: url!)
                                    let session = URLSession.shared
                                    session.dataTask(with: request) { (data, response, error) in
                                        if error == nil, let data = data, let response = response as? HTTPURLResponse {
                                            // HTTPヘッダの取得
                                            print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                                            // HTTPステータスコード
                                            print("statusCode: \(response.statusCode)")
                                            print(String(data: data, encoding: String.Encoding.utf8) ?? "")
                                        }
                                    }.resume()
                                    view.navigationController?.popViewController(animated: true)
                                }
                            }
                            break
                        case .failure(let error):
                            HUD.hide { (_) in
                                HUD.flash(.label(error.domain), delay: 1.0) { _ in
                                    print("投稿失敗\(error)")
                                }
                            }
                        }
                    }
                case .failure(let error):
                    HUD.hide { (_) in
                        HUD.flash(.label(error.domain), delay: 1.0) { _ in
                            print("投稿失敗\(error)")
                        }
                    }
                }
            }
        }
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "MMddHHmmss"
        return formatter.string(from: date)
    }
    
}
