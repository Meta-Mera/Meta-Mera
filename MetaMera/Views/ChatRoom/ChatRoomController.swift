//
//  chatRoomController.swift
//  MetaMera
//
//  Created by Jim on 2022/06/16.
//

import Foundation
import UIKit

class ChatRoomController: UIViewController, UITextFieldDelegate{
    
    private let cellId = "ChatRoomTableViewCell"
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    @IBOutlet weak var backImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil) , forCellReuseIdentifier: cellId)
        
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
        
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
    }
    
    
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
        print("etst")
        self.view.endEditing(true)
    }
    
}



extension ChatRoomController: ChatViewControllerDelegate{
    func tappedSendButton(text: String) {
        print(text)
    }
}

extension ChatRoomController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
//        cell.backgroundColor = .lightGray
        return cell
        
    }
    
    
}
