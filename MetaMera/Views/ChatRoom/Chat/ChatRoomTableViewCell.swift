//
//  chatRoomTableViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/06/17.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var dateLabelView: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
//        userIconImageView.layer.cornerRadius = 30
//        messageTextView.layer.cornerRadius = 15
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
 
