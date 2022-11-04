//
//  PostImageTableViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/07/25.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import AlamofireImage

class PostImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postUserNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var commentTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    
    
    var delegate: UserProfileProtocol?
    var iLiked = false
    
    let generator = UINotificationFeedbackGenerator()
    
    
    var post: Post!
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
        profileImageView.isUserInteractionEnabled = true
        postUserNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushPostUser(_:))))
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushPostUser(_:))))
        
        backgroundColor = .clear
        
        
    }
    
    @objc func pushPostUser(_ sender: Any){
        print("ユーサラベルがタップされました。\(postUser?.userName)")
        delegate?.tapUser(user: postUser!)
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
            self?.profileImageView.loadImageAsynchronously(url: URL(string:(self?.postUser!.profileImage)!))
        }
        postImageView.af.setImage(withURL: URL(string: post.rawImageUrl)!, placeholderImage: UIImage(named: "ロゴ"))
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
    
    @IBAction func pushLike(_ sender: Any) {
        if(iLiked){
            likeButton.setImage(UIImage(named: "ハート(押す前)"), for: .normal)
        }else{
            likeButton.setImage(UIImage(named: "ハート(押した後)"), for: .normal)
        }
        iLiked.toggle()
    }
    
    

}
