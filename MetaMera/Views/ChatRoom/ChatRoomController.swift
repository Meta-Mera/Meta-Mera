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

class ChatRoomController: UIViewController, UITextFieldDelegate{
    
    var postId: String!
    var post: Post!
    var user: User?
    
    
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
    
//    static let shared = Profile()
    
    var image: UIImage!
    
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
//        postImageView.image = image
        setUpNotification()
        fetchMessages()
    }
    
    //画面から離れたとき
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tearDownNotification()
    }
    
    //MARK: 前の画面に戻る
    @objc func backView(_ sender: Any){
        print("push back image")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private lazy var chatView: ChatViewController = {
        let view = ChatViewController()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
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
        
        Firestore.firestore().collection("Posts").document(postId).collection("comments").addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let comment = Comment(dic: dic)
                    Firestore.firestore().collection("Users").document(comment.uid).getDocument { (user, err) in
                        if let err = err {
                            print("ユーザー情報の取得に失敗しました。\(err)")
                            return
                        }
                        
                        guard let dic = user?.data() else { return }
                        let user = User(dic: dic, uid: comment.uid)
                        comment.sendUser = user
                        self.messages.append(comment)
                        self.messages.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date < m2Date
                        }
                        print("ユーザー情報の取得に成功しました。")
                        
                        self.chatRoomTableView.reloadData()
                    }
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
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
            "message": text
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
        if indexPath.section == 0 {
            let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: tableUpCellId, for: indexPath) as! PostImageTableViewCell

            cell.postImageView.image = image
            cell.post = post
//            let border = CALayer()
//            border.frame = CGRect(x: 0, y: cell.frame.height - 20, width: cell.frame.width, height: 0.25)
//            border.backgroundColor = UIColor.black.cgColor
//            cell.layer.addSublayer(border)
            

            return cell
        }else {
            let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
    //        cell.messageTextView.text = messages[indexPath.row]
            cell.messageText = messages[indexPath.row]
            cell.messageTextView.backgroundColor = UIColor.chatTextBackground
            cell.messageTextView.textColor = UIColor.chatText
            return cell
        }
        
        
//        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
////        cell.messageTextView.text = messages[indexPath.row]
//        cell.messageText = messages[indexPath.row]
//        cell.messageTextView.backgroundColor = UIColor.chatTextBackground
//        cell.messageTextView.textColor = UIColor.chatText
//        return cell
//
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
}
