//
//  PostImageTableViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/07/25.
//

import Foundation
import UIKit
import Firebase


class PostImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postUserNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    
//    var messageText: Comment?{
//        didSet{
//
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configView() {
        
        backgroundColor = .clear
        
    }
    
}
