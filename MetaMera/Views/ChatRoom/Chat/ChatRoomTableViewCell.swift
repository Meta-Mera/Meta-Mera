//
//  ChatRoomTableViewCell.swift
//  MetaMera
//
//  Created by 松丸真 on 2022/06/21.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    
    var messageText: String?{
        didSet{
            guard let text = messageText else { return }
            let width = estimateFrameForTextView(text: text).width + 20
            
            messageTextViewWidthConstraint.constant = width
            messageTextView.text = " "+text
        }
    }
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
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
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        messageTextView.layer.cornerRadius = 10.0
        
        backgroundColor = .clear
        
        switch Profile.shared.updateProfileImage() {
        case .success(let image):
            userIconImageView.setImage(image: image, name: Profile.shared.loginUser.uid)
        case .failure(_):
            break
        }
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
}
