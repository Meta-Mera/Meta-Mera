//
//  PhotosCollectionViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/11/24.
//

import UIKit
import Firebase
import AlamofireImage

class PhotosCollectionViewCell: UICollectionViewCell {
    
    var pictureTapDelegate: PictureTapDelegate?
    var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var postCount: Int = 0

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
    
    func configView(){
        collectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "PictureCollectionViewCell")
    }
    
    let imageCache = AutoPurgingImageCache()
    

}

extension PhotosCollectionViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath) as? PictureCollectionViewCell else {
            return UICollectionViewCell()
        }
        let postImageURL = URL(string: posts[indexPath.row].rawImageUrl)!
        
        let imageRequest = URLRequest(url: postImageURL)
        
        if let cachedImage = imageCache.image(for: imageRequest, withIdentifier: postImageURL.absoluteString) {
//            cell.postImageView.image = cachedImage
            DispatchQueue.main.async {
                cell.postImageView.image = cachedImage
            }
        } else {
            cell.postImageView.af.setImage(withURLRequest: imageRequest, placeholderImage: Asset.Images.ロゴ.image, completion:  { response in
                if case .success(let image) = response.result {
                    self.imageCache.add(image, for: imageRequest, withIdentifier: postImageURL.absoluteString)
                }
            })
        }
        if posts[indexPath.row].hidden {
            cell.hidenPostImage.isHidden = false
            cell.postImageView.alpha = 0.1
        }
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postCount
    }
}

extension PhotosCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PictureCollectionViewCell {
            guard let post = cell.post else {
                print("投稿ID取得失敗")
                return
            }
            pictureTapDelegate?.picutureTap(post: post)
        }
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
