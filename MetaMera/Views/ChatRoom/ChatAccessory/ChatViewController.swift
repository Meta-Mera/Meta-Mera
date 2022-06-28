//
//  ChatViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/18.
//

import UIKit

protocol ChatViewControllerDelegate: class{
    func tappedSendButton(text: String)
}

class ChatViewController: UIView{

    @IBOutlet weak var inputChatText: UITextView!
    @IBOutlet weak var ChatSendButton: UIButton!
    
    weak var delegate: ChatViewControllerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight

        inputChatText.delegate = self
    }
    
    private func setupViews(){
        
        
        inputChatText.layer.cornerRadius = 15
        inputChatText.layer.borderColor = UIColor.rgb(red: 238, green: 238, blue: 238).cgColor
        inputChatText.layer.borderWidth = 1
        
        
//        ChatSendButton.layer.cornerRadius = 10
//        ChatSendButton.imageView?.contentMode = .scaleAspectFill
        ChatSendButton.contentHorizontalAlignment = .fill
        ChatSendButton.contentVerticalAlignment = .fill
        ChatSendButton.isEnabled = false
        
        inputChatText.text = ""
    }
    
    func removeText(){
        inputChatText.text = ""
        ChatSendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func nibInit(){
        let nib = UINib(nibName: "ChatViewController", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = inputChatText.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
}

extension ChatViewController: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            ChatSendButton.isEnabled = false
        }else{
            ChatSendButton.isEnabled = true
        }
    }
}
