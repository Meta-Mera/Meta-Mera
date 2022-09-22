//
//  PostTableViewCell.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import UIKit
import Firebase
import Nuke

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    var post: Post?{
        didSet{
            
        }
    }
    
    var postUser: User?{
        didSet{
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        updateImageTableView()
    }
    
    private func configView() {
        
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        
    }
    
    private func updateImageTableView(){
        postDateLabel.text = dateFormatterForDateLabel(date: (post?.createdAt.dateValue())!)
        
        Firestore.firestore().collection("Users").document(post!.postUserUid).getDocument {[weak self] (userSnapshot, err) in
            if let err = err {
                print("ユーザ情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let dic = userSnapshot?.data() else { return }
            guard let postUserUid = self?.post?.postUserUid else { return }
            self?.postUser = User(dic: dic, uid: postUserUid)
            
            self?.userNameLabel.text = self?.postUser?.userName
            self?.postTextView.text = self?.post?.comment.replacingOccurrences(of: "\\\\n", with: "\n").replacingOccurrences(of: "\\", with: "")
            if let url = URL(string:(self?.postUser?.profileImage)!){
                Nuke.loadImage(with: url, into: (self?.postImageView)!)
            }
            
            
        }
            
    }
    
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
