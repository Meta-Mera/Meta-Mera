//
//  PhotosCollectionViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/11/24.
//

import UIKit
import Firebase

class PhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    var user: User!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }
    
    private func configView(){
        collectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "PictureCollectionViewCell")
    }
    
    var postCount: Int?
    var posts = [Post]()
    
    func getUserPostData(){
        Firestore.firestore().collection("Posts").whereField("postUserUid", isEqualTo: user.uid).getDocuments(completion: {[weak self] (snapshot, error) in
            if let error = error {
                print("投稿データの取得に失敗しました。\(error)")
                return
            }
            
            self?.postCount = snapshot!.documents.count
            for document in snapshot!.documents {
                let post = Post(dic: document.data(), postId: document.documentID)
                self?.posts.append(post)
                self?.posts.sort { (m1, m2) -> Bool in
                    let m1Date = m1.createdAt.dateValue()
                    let m2Date = m2.createdAt.dateValue()
                    return m1Date < m2Date
                }
                
                
            }
        })

    }

}

extension PhotosCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath) as! PictureCollectionViewCell
        if let postImageURL = URL(string: posts[indexPath.row].rawImageUrl){
            cell.postImageView.af.setImage(withURL: postImageURL)
        }
        return cell
//        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let postCount = postCount else{
            return 0
        }
        return postCount
    }
}

extension PhotosCollectionViewCell: UICollectionViewDelegateFlowLayout {
    // size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width / 3
        return .init(width: size, height: size)
    }
    
    // line margin
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    // intent margin
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    // padding
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
