//
//  ChatRoomTableViewCell.swift
//  MetaMera
//
//  Created by 松丸真 on 2022/06/21.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configView() {
        userIconImageView.layer.cornerRadius = 30.0
        messageTextView.layer.cornerRadius = 10.0
    }
}
