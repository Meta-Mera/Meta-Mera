//
//  PhotoTableViewCell.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTextView: PlaceTextView!
    @IBOutlet weak var photoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }
    
    func configView(){
        
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.cornerRadius = 10.0
        commentTextView.layer.masksToBounds = true
        commentTextView.placeHolder = "キャプションを入力"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
