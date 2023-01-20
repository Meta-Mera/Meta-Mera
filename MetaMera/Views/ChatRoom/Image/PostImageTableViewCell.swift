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
    var goodDelegate: goodDelegate?
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
    
    func getGood(){
        Firestore.firestore().collection("Likes").whereField("uid", isEqualTo: Profile.shared.loginUser.uid).whereField("postId", isEqualTo: post.postId!).getDocuments(completion: { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }else {
                
                guard snapshot!.documents.first?.value != nil else {
                    //いいねしてない
                    self?.iLiked = false
                    self?.likeButton.setImage(Asset.Images.notGood.image, for: .normal)
                    self?.goodDelegate?.good(good: false)
                    return
                }
                //いいねしてる
                self?.iLiked = true
                self?.likeButton.setImage(Asset.Images.good.image, for: .normal)
                self?.goodDelegate?.good(good: true)
                return
            }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateImageTableView()
    }
    
    func configView() {
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        if(iLiked){
            likeButton.setImage(Asset.Images.good.image, for: .normal)
        }else{
            likeButton.setImage(Asset.Images.notGood.image, for: .normal)
        }
        
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
            
            if( (self?.postUser?.ban)! || (self?.postUser?.deleted)!){
                self?.postTextView.text = "Submission has been deleted or hidden."
                self?.postDateLabel.text = ""
                self?.postImageView.setImage(image: Asset.Images.ロゴ.image, name: "")
                if ((self?.postUser?.deleted) != nil){
//                    FirebaseManager.post.document(id: (self?.post.postId)!).updateData([
//                        "deleted":true
//                    ]){ err in
//                        if let err = err {
//                            print("投稿の削除に失敗しました。\(err)")
//                        }
//                    }
                    return
                }
            }else{
                self?.postUserNameLabel.text = self?.postUser?.userName
                self?.postUserNameLabel.accessibilityIdentifier = self?.postUser?.uid
                self?.postTextView.text = self?.post?.comment.replacingOccurrences(of: "\\\\n", with: "\n").replacingOccurrences(of: "\\", with: "")
                self?.profileImageView.loadImageAsynchronously(url: URL(string:(self?.postUser!.profileImage)!))
            }
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
        iLiked.toggle()
        if(iLiked){
            likeButton.setImage(Asset.Images.good.image, for: .normal)
            goodDelegate?.good(good: true)
        }else{
            likeButton.setImage(Asset.Images.notGood.image, for: .normal)
            goodDelegate?.good(good: false)
        }
    }
    
    

}
