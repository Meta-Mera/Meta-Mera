//
//  PostImageTableViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/07/25.
//

import Foundation
import UIKit
import Firebase
import Nuke


class PostImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postUserNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var commentTextViewWidthConstraint: NSLayoutConstraint!
    
    var post: Post?{
        didSet{
            
        }
    }
    var postUser: User?{
        didSet{
            
        }
    }
    
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
        
        updateImageTableView()
    }
    
    private func configView() {
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        
        postUserNameLabel.isUserInteractionEnabled = true
        postUserNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushUserLabel(_:))))
        
        backgroundColor = .clear
        
        
    }
    
    @objc func pushUserLabel(_ sender: Any){
//        Goto.Profile(view: self, user: )

    }
    
    private func updateImageTableView(){
        postDateLabel.text = dateFormatterForDateLabel(date: (post?.createdAt.dateValue())!)
        
        Firestore.firestore().collection("Users").document(post!.postUserUid).getDocument {[weak self] (userSnapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            guard let dic = userSnapshot?.data() else { return }
            guard let postUserUid = self?.post?.postUserUid else { return }
            self?.postUser = User(dic: dic,uid: postUserUid)
            
            self?.postUserNameLabel.text = self?.postUser?.userName
            self?.postUserNameLabel.accessibilityIdentifier = self?.postUser?.uid
            self?.postTextView.text = self?.post?.comment.replacingOccurrences(of: "\\\\n", with: "\n").replacingOccurrences(of: "\\", with: "")
            if let url = URL(string: (self?.postUser?.profileImage)!){
                Nuke.loadImage(with: url, into: (self?.profileImageView)!)
            }
        }
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect{
        let size = CGSize(width: 500, height: 5000)
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
    
}
