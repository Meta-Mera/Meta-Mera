//
//  chatRoomTableViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/06/17.
//

import UIKit

class chatRoomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
 
