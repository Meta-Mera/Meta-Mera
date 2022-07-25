//
//  PostViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/07/20.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import Firebase

class PostViewController: UIViewController, UITextFieldDelegate {
    
    var postId: String!
    var post: Post?
    var user: User?
    
    private let cellId = "ChatRoomTableViewCell"
    private var messages = [Comment]()
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var backImageView: UIImageView!
    
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
        
        scrollView.delegate = self
//        mainScrollView.delegate = self
        self.scrollView.maximumZoomScale = 1.5
        self.scrollView.maximumZoomScale = 2
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil) , forCellReuseIdentifier: cellId)
        
        chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        chatRoomTableView.backgroundColor = UIColor.chatRoomBackground
        ChatViewController().inputChatText.layer.backgroundColor = UIColor.inputChatTextBackground.cgColor
        
        
        
        //MARK: ピンチインピンチアウト
        let recognizer = UITapGestureRecognizer(target: self,action: #selector(onDoubleTap(_:)))
        recognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(recognizer)

    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        print("2呼ばれてる")
        return postImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("3呼ばれた")
        if !scrollView.isZooming {
            print("ズームされてない")
//            scrollView.zoom(to: scrollView.frame, animated: true)
        }else{
            print("ズームされてる")
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        print("1呼ばれてるかも")
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
    
    //MARK: 前の画面に戻る
    @objc func backView(_ sender: Any){
        print("push back image")
        self.dismiss(animated: true, completion: nil)
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
    
    @objc func onDoubleTap(_ sender: UITapGestureRecognizer) {
        let scale = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
        
        if scale != scrollView.zoomScale {
            let tapPoint = sender.location(in: postImageView)
            let size = CGSize(width: scrollView.frame.size.width / scale,
                              height: scrollView.frame.size.height / scale)
            let origin = CGPoint(x: tapPoint.x - size.width / 2,
                                 y: tapPoint.y - size.height / 2)
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        }
        else {
            scrollView.zoom(to: scrollView.frame, animated: true)
        }
    }
    
}

extension PostViewController: ChatViewControllerDelegate {
    
    
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

extension PostViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if indexPath.section == 0 {
//            let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
//    //        cell.messageTextView.text = messages[indexPath.row]
//            cell.messageText = messages[indexPath.row]
//            cell.messageTextView.backgroundColor = UIColor.chatTextBackground
//            cell.messageTextView.textColor = UIColor.chatText
//            return cell
//        }else {
//            let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
//    //        cell.messageTextView.text = messages[indexPath.row]
//            cell.messageText = messages[indexPath.row]
//            cell.messageTextView.backgroundColor = UIColor.chatTextBackground
//            cell.messageTextView.textColor = UIColor.chatText
//            return cell
//        }
        
        
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
//        cell.messageTextView.text = messages[indexPath.row]
        cell.messageText = messages[indexPath.row]
        cell.messageTextView.backgroundColor = UIColor.chatTextBackground
        cell.messageTextView.textColor = UIColor.chatText
        return cell
        
    }
    
    
}

