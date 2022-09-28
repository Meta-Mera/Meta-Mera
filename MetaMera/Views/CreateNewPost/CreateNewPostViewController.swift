//
//  CreateNewPostViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/07/15.
//

import Foundation
import UIKit
import Photos

class CreateNewPostViewController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var debugButton: UIButton!
    
    let postUploadModel = PostUploadModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    func configView(){
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
        
    }
    
    @IBAction func pushButton(_ sender: Any) {
        
        postUploadModel.upload(postItem: .init(
            areaId: "mydtfzFYDHjqNNSfYW55",
            genreId: "pSuty2KKoROCGTcAavNZ",
            rawImageUrl: "https://firebasestorage.googleapis.com/v0/b/metamera-e2b4b.appspot.com/o/posts%2Fraw%2F20220912-IMG_2595.jpg?alt=media&token=3bd751c0-d37c-4179-99e3-c03b9cce419d",
            editedImageUrl: "https://firebasestorage.googleapis.com/v0/b/metamera-e2b4b.appspot.com/o/posts%2Fraw%2F20220912-IMG_2595.jpg?alt=media&token=3bd751c0-d37c-4179-99e3-c03b9cce419d",
            latitude: 35.748403038713136,
            longitude: 139.48104265054985,
            altitude: 150,
            comment: "少し天気が悪かったけど綺麗なお城でした！\\\\n#名古屋 \\\\n#名古屋城"
        )) { result in
            switch result {
            case .success(_):
                print("投稿成功")
            case .failure(let error):
                print("投稿失敗\(error)")
            }
        }
        
    }
    
    @objc func backView(_ sender: Any){
        print("push back image")
        //        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
