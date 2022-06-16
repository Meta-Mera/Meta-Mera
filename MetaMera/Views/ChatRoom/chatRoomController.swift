//
//  chatRoomController.swift
//  MetaMera
//
//  Created by Jim on 2022/06/16.
//

import Foundation
import UIKit

class chatRoomController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userIcon: UIImageView!
    
    override func viewDidLoad() {
        userIcon.layer.cornerRadius = 30
    }
    
    private lazy var chatView: ChatViewController = {
        let view = ChatViewController()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
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
    
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}



extension chatRoomController: ChatViewControllerDelegate{
    func tappedSendButton(text: String) {
        print(text)
    }
}
