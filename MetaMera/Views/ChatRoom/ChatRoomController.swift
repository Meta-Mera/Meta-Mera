//
//  chatRoomController.swift
//  MetaMera
//
//  Created by Jim on 2022/06/16.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import Firebase
import Alamofire
import AlamofireImage

class ChatRoomController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate{
    
    var postId: String!
    var post: Post!
    var user: User?
    var imageUrl: URL!
    
    var iLiked = false
    
    
    private let cellId = "ChatRoomTableViewCell"
    private let tableUpCellId = "PostImageTableViewCell"
    private let accessoryHeight: CGFloat = 150
    private let tableViewContentInset : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private let tableViewIndicatorInser : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private var safaAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    private var messages = [Comment]()
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var optionButton: UIButton!
    
    //    static let shared = Profile()
    
//    var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNotification()
        tearDownNotification()
        configView()
    }
    
    
    
    
        
    func configView(){
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "PostImageTableViewCell", bundle: nil) , forCellReuseIdentifier: tableUpCellId)
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil) , forCellReuseIdentifier: cellId)
        chatRoomTableView.rowHeight = UITableView.automaticDimension
        
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInser
        chatRoomTableView.keyboardDismissMode = .interactive
        
        //戻るボタン
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
        
        //        chatRoomTableView.backgroundColor = .rgb(red: 240, green: 240, blue: 240)
        //        chatRoomTableView.backgroundColor = UIColor.dynamicColor(light: .rgb(red: 240, green: 240, blue: 240), dark: .rgb(red: 0, green: 0, blue: 0))
        chatRoomTableView.backgroundColor = UIColor.chatRoomBackground
        ChatViewController().inputChatText.layer.backgroundColor = UIColor.inputChatTextBackground.cgColor
        
        optionButton.imageView?.contentMode = .scaleAspectFill
        optionButton.contentHorizontalAlignment = .fill
        optionButton.contentVerticalAlignment = .fill
        
//        image.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "ロゴ"))
        
    }
    
    
    //キーボードが表示されたときの動作を追加
    private func setUpNotification() {
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    //キーボードが表示されたときの動作を削除
    private func tearDownNotification() {
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    //画面遷移しようとしたとき
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messages.removeAll()
        //        postImageView.image = image
        setUpNotification()
        fetchMessages()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        Firestore.firestore().collection("Posts").document(postId).collection("likeUsers").whereField("uid", isEqualTo: Profile.shared.loginUser.uid).getDocuments(completion: { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }else {
                guard snapshot!.documents.first?.value != nil else {
                    //いいねしてない
                    self?.iLiked = false
                    return
                }
                //いいねしてる
                self?.iLiked = true
                
            }
            
        })
    }
    
    //画面から離れたとき
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tearDownNotification()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        Firestore.firestore().collection("Posts").document(postId).collection("likeUsers").whereField("uid", isEqualTo: Profile.shared.loginUser.uid).getDocuments(completion: { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }else {
                guard snapshot!.documents.first?.value != nil else {
                    //いいねしてない
                    if((self?.iLiked)!){
                        let docData = ["uid" : Profile.shared.loginUser.uid,
                                       "createAt": Timestamp()] as [String : Any]
                        print("データなし")
                        Firestore.firestore().collection("Posts").document((self?.postId)!).collection("likeUsers").document(Profile.shared.loginUser.uid).setData(docData) { error in
                            if let error = error {
                                print("いいねの登録に失敗しました。\(error)")
                                return
                            }
                            print("いいねの登録に成功しました。")
                        }
                    }
                    return
                }
                //いいねしてる
                if(!(self?.iLiked)!){
                    Firestore.firestore().collection("Posts").document((self?.postId)!).collection("likeUsers").document(Profile.shared.loginUser.uid).delete(){ error in
                        if let error = error {
                            print("いいねの削除に失敗\(error)")
                        }
                    }
                }
            }
            
        })
        messages.removeAll()
    }
    
    
    //MARK: - ハンバーガーボタン
    @IBAction func pushOptionButton(_ sender: Any) {
        
        // styleをActionSheetに設定
        let alertSheet = UIAlertController(title: "Option", message: "What happened?", preferredStyle: UIAlertController.Style.actionSheet)
        
        // アクションを追加.
        
        if post.postUserUid == Profile.shared.loginUser.uid {
            
            let edit = UIAlertAction(title: LocalizeKey.edit.localizedString(), style: UIAlertAction.Style.default, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                print("edit")
                
            })
            
            alertSheet.addAction(edit)
            
            //非表示、再表示化
            if post.hidden {
                let show = UIAlertAction(title: LocalizeKey.show.localizedString(), style: UIAlertAction.Style.default, handler: {[weak self]
                    (action: UIAlertAction!) -> Void in
                    print("hide")
                    Firestore.firestore().collection("Posts").document((self?.postId)!).updateData([
                        "hidden": false
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("再表示化成功")
                        }
                    }
                })
                alertSheet.addAction(show)
            }else {
                let hide = UIAlertAction(title: LocalizeKey.hide.localizedString(), style: UIAlertAction.Style.default, handler: {[weak self]
                    (action: UIAlertAction!) -> Void in
                    print("hide")
                    Firestore.firestore().collection("Posts").document((self?.postId)!).updateData([
                        "hidden": true
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("非表示化成功")
                        }
                    }
                })
                alertSheet.addAction(hide)
            }
            
            //投稿削除
            let delete = UIAlertAction(title: LocalizeKey.delete.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                print("delete")
                Firestore.firestore().collection("Posts").document((self?.postId)!).updateData([
                    "deleted": true
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("削除成功")
                    }
                }
            })
            
            
            
            alertSheet.addAction(delete)
            
        } else {
            
            let report = UIAlertAction(title: LocalizeKey.report.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                print("Report")
                self!.gotoReport()
            })
            
            alertSheet.addAction(report)
        }
        
        let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        alertSheet.addAction(cancel)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    //MARK: - ハンバーガーボタン
    
    //MARK: 前の画面に戻る
    @objc func backView(_ sender: Any){
        print("push back image")
        //        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func gotoReport(){
        Goto.ReportViewController(view: self,postId: postId)
    }
    
    
    private lazy var chatView: ChatViewController = {
        let view = ChatViewController()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.inputChatText.layer.backgroundColor = UIColor.inputChatTextBackground.cgColor
        view.delegate = self
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return chatView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification: Notification){
        guard let userInfo = notification.userInfo else { return }

        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {

            if keyboardFrame.height <= accessoryHeight { return }
            let bottom = keyboardFrame.height - 40
            let moveY = (bottom - safaAreaBottom)
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
            
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
//            chatRoomTableView.contentOffset = CGPoint(x: 0,y: 0)
            
        }
    }
    
    @objc func hideKeyboard(){
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInser
    }
    
    
    
    private func fetchMessages() {
        
        
//        Firestore.firestore().collection("Users")
//            .getDocuments { [weak self] snap, err in
//                if let err = err {
//                    print("err", err)
//                    return
//                }
//
//                guard let userDocs = snap?.documents else {
//                    print("not found data")
//                    return
//                }
//
//                Firestore.firestore().collection("Posts").document(self!.postId).collection("comments")
//                    .addSnapshotListener { [weak self] (snapshots, err) in
//                        if let err = err {
//                            print("err", err)
//                            return
//                        }
//
//                        guard let commentDocs = snapshots?.documentChanges else {
//                            print("not found data")
//                            return
//                        }
//
//                        let dispatchGroup = DispatchGroup()
//                        let dispatchQueue = DispatchQueue(label: "com.MetaMera.comment")
//
//                        commentDocs.forEach { documentChange in
//
//                            dispatchGroup.enter()
//                            dispatchQueue.async {
//                                switch documentChange.type {
//                                case .added:
//
//                                    let dic = documentChange.document.data()
//                                    let comment = Comment(dic: dic,commentId: documentChange.document.documentID)
//
//                                    if !comment.deleted {
//
//                                        for userDoc in userDocs where userDoc.documentID == comment.uid {
//                                            let user = User(dic: userDoc.data(), uid: userDoc.documentID)
//                                            comment.sendUser = user
//                                            self?.messages.append(comment)
//                                            self?.messages.sort { (m1, m2) -> Bool in
//                                                let m1Date = m1.createdAt.dateValue()
//                                                let m2Date = m2.createdAt.dateValue()
//                                                return m1Date < m2Date
//                                            }
//                                            print("ユーザー情報の取得に成功しました。")
//                                        }
//                                    }
//
//
//                                case .modified, .removed:
//                                    break
//                                }
//                                dispatchGroup.leave()
//                            }
//                        }
//
//                        dispatchGroup.notify(queue: dispatchQueue) {
//                            DispatchQueue.main.async {
//                                self?.chatRoomTableView.reloadData()
//                            }
//                        }
//
//
//
//                    }
//            }
        
        
        
        
        
        
        
        

        Firestore.firestore().collection("Posts").document(postId).collection("comments").addSnapshotListener {[weak self] (snapshots, err) in

            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }

            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "com.MetaMera.comment")

            snapshots?.documentChanges.forEach({ (documentChange) in

                dispatchGroup.enter()
                dispatchQueue.async {
                    switch documentChange.type {
                    case .added, .modified:
                        let dic = documentChange.document.data()
                        let comment = Comment(dic: dic,commentId: documentChange.document.documentID)
                        print("comment deleted:\(comment.deleted)")
                        if !comment.deleted {
                            Firestore.firestore().collection("Users").document(comment.uid).getDocument { (user, err) in
                                if let err = err {
                                    print("ユーザー情報の取得に失敗しました。\(err)")
                                    return
                                }

                                guard let dic = user?.data() else { return }
                                let user = User(dic: dic, uid: comment.uid)
                                comment.sendUser = user
                                self?.messages.append(comment)
                                self?.messages.sort { (m1, m2) -> Bool in
                                    let m1Date = m1.createdAt.dateValue()
                                    let m2Date = m2.createdAt.dateValue()
                                    return m1Date < m2Date
                                }
                                print("ユーザー情報の取得に成功しました。")

    //                            self?.chatRoomTableView.reloadData()
                                dispatchGroup.leave()
                            }
                        }else {
                            dispatchGroup.leave()
                        }
                    case .removed:
                        print("nothing to do")
                        dispatchGroup.leave()
                    }
                }

            })

            dispatchGroup.notify(queue: dispatchQueue) {
                DispatchQueue.main.async {

                    self?.chatRoomTableView.reloadData()
                }
            }
        }
    }
    
    
}



//MARK: sendボタンを押した時
extension ChatRoomController: ChatViewControllerDelegate {
    
    
    func tappedSendButton(text: String) {
        
//        messages.append(text)
//        chatView.removeText()
//        chatRoomTableView.reloadData()
        
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
//        guard let chatroomDocId = chatroom?.documentId else { return }
//        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let messageId = randomString(length: 20)

        let docData = [
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text,
            "hidden": false,
            "deleted": false
            ] as [String : Any]
        Firestore.firestore().collection("Posts").document(postId).collection("comments").addDocument(data: docData){ [weak self] (err) in
            if let err = err{
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            print("メッセージの保存に成功しました。")
            self?.chatView.removeText()
            
            
        }

    }
    
    
}

extension ChatRoomController: UITableViewDelegate, UITableViewDataSource{
    
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            chatRoomTableView.estimatedRowHeight = 500
            return UITableView.automaticDimension
        }else{
            chatRoomTableView.estimatedRowHeight = 20
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return messages.count
        }else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath.section: ",indexPath.section)
        print("message", messages)
        if indexPath.section == 0 {
            let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: tableUpCellId, for: indexPath) as! PostImageTableViewCell

            cell.post = post
            cell.delegate = self
            cell.goodDelegate = self
            cell.iLiked = iLiked
            cell.configView()

            return cell
        }else {
            let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
    //        cell.messageTextView.text = messages[indexPath.row]
            cell.messageText = messages[indexPath.row]
            cell.messageTextView.backgroundColor = UIColor.chatTextBackground
            cell.messageTextView.textColor = UIColor.chatText
            cell.delegate = self
            cell.optionDelegate = self
            if (Profile.shared.loginUser.uid == messages[indexPath.row].uid) || (Profile.shared.loginUser.uid == post.postUserUid) {
                cell.optionButton.isHidden = false
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = .gray
            
//            let titleLabel = UILabel()
//            titleLabel.text = "header"
//            titleLabel.frame = headerView.frame
//            titleLabel.textColor = .white
//
//            headerView.addSubview(titleLabel)
            
            return headerView
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("tapped table view")
            print("message:",messages[indexPath.row].message)
        }
    
}

extension ChatRoomController: UserProfileProtocol{
    func tapUser(user: User) {
        Goto.ProfileViewController(view: self, user: user)
//        Goto.UserProfile(view: self, user: user)
    }
}

extension ChatRoomController: commentDelegate {
    
    func commentOption(commentId: String) {
        print("コメントオプション")
        // styleをActionSheetに設定
        let alertSheet = UIAlertController(title: "Option", message: "What happened?", preferredStyle: UIAlertController.Style.actionSheet)
        
        // アクションを追加
        //投稿削除
        let delete = UIAlertAction(title: LocalizeKey.delete.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
            (action: UIAlertAction!) -> Void in
            print("delete")
            Firestore.firestore().collection("Posts").document((self?.postId)!).collection("comments").document(commentId).updateData([
                "deleted": true
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    
                    if let index = self?.messages.firstIndex(where: { $0.commentId == commentId }) {
                        self?.messages.remove(at: index)
                        self?.chatRoomTableView.reloadData()
                    }
                    
                    
                    print("削除成功")
                }
            }
        })
        
        
        
        alertSheet.addAction(delete)
        
        let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        alertSheet.addAction(cancel)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
}

extension ChatRoomController: goodDelegate {
    
    func good() {
        iLiked.toggle()
        print("\(iLiked)")
    }
}
