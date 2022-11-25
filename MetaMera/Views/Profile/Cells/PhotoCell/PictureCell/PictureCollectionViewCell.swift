//
//  PictureCollectionViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/11/24.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.image = nil
    }

}
