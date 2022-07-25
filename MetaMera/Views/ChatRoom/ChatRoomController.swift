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
    var post: Post?
    var user: User?
    
    
    private let cellId = "ChatRoomTableViewCell"
    private var messages = [Comment]()
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    
//    static let shared = Profile()
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil) , forCellReuseIdentifier: cellId)
        
        chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
//        chatRoomTableView.keyboardDismissMode = .interactive
//        chatRoomTableView.transform = CGAffineTransform(a: 0, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
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
        postImageView.setImage(image: image, name: "Uz93q4hTLBHvLUFglhxp")
        setUpNotification()
        fetchMessages()
    }
    
    //画面から離れたとき
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tearDownNotification()
    }
    
    //TODO: チャットルームに入ったときにFirestoreから最新の情報を取得したい
//    private func fetchChatRoomInFromFirestore(){
//
//        Firestore.firestore().collection("Posts").document(postImageView.getName() ?? "").getDocument { snapshots, err in
//            if let err = err{
//                print("チャットルームの取得に失敗\(err)")
//                return
//            }
//
//            let dic = snapshots?.data()
//            print("dic:",dic)
//        }
//    }
    
    //MARK: 前の画面に戻る
    @objc func backView(_ sender: Any){
        print("push back image")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private lazy var chatView: ChatViewController = {
        let view = ChatViewController()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 150)
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
//        guard let userInfo = notification.userInfo else { return }
//
//        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
//
//            let top = keyboardFrame.height
//            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
//        }
    }
    
    @objc func hideKeyboard(){

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
                        
                        self.chatRoomTableView.reloadData()
                        //                self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
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
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
//        cell.messageTextView.text = messages[indexPath.row]
        cell.messageText = messages[indexPath.row]
        cell.messageTextView.backgroundColor = UIColor.chatTextBackground
        cell.messageTextView.textColor = UIColor.chatText
        return cell
        
    }
    
    
}
