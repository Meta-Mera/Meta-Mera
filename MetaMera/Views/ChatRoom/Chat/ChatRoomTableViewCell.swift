//
//  ChatRoomTableViewCell.swift
//  MetaMera
//
//  Created by 松丸真 on 2022/06/21.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    
    var messageText: Comment?{
        didSet{
//            guard let text = messageText else { return }
//            let width = estimateFrameForTextView(text: text).width + 20
//
//            messageTextViewWidthConstraint.constant = width
//            messageTextView.text = " "+text
        }
    }
    
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sendUser: UILabel!
    
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        checkWhichUserMessage()
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
    
    private func checkWhichUserMessage() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let message = messageText else { return}
        guard let sendUserProfileImageUrl = message.sendUser?.profileImage else {return}
        
        sendUser.text = message.sendUser?.userName
        
        messageTextView.text = message.message
        let witdh = estimateFrameForTextView(text: message.message).width + 20
        messageTextViewWidthConstraint.constant = witdh
        dateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
        if let url = URL(string: sendUserProfileImageUrl){
            Nuke.loadImage(with: url, into: userIconImageView)
        }
        
        
//        userIconImageView.setImage(url: sendUserProfileImageUrl, name: message.uid)
//        switch convertUrlToImage(imageUrl: sendUserProfileImageUrl){
//
//        case .success(let image):
//            userIconImageView.setImage(image: image, name: message.uid)
//
//        case .failure(_):
//            return
//        }
        
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func convertUrlToImage(imageUrl: String) -> Result<UIImage, Error> {
        guard let url = URL(string: imageUrl) else { return .failure(NSError(domain: "Could not convert from URL to image.", code: 404))}
        guard let imageData = try? Data(contentsOf: url) else { return .failure(NSError(domain: "Could not convert from URL to image.", code: 404))}
        guard let image = UIImage(data: imageData)  else { return .failure(NSError(domain: "Could not convert from URL to image.", code: 404))}
        return .success(image)
    }
    
}
