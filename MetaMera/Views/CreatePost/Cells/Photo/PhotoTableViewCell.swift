//
//  PhotoTableViewCell.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTextView: PlaceTextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var limitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }
    
    var delegate : CreatePostDelegate?
    
    func configView(){
        limitLabel.text = ""
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.cornerRadius = 10.0
        commentTextView.layer.masksToBounds = true
        commentTextView.placeHolder = "キャプションを入力"
        commentTextView.delegate = self
    }
    
    
    @IBAction func pushPhotoButton(_ sender: Any) {
        delegate?.pushPhotoButton()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension PhotoTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: .newlines)//既に存在する改行数
        let newLines = text.components(separatedBy: .newlines)//新規改行数
        let linesAfterChange = existingLines.count + newLines.count - 1 //最終改行数。-1は編集したら必ず1改行としてカウントされるから。
        return linesAfterChange <= 5 && textView.text.count + (text.count - range.length) <= 200
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.limitLabel.text = "\(textView.text.count)/200"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.limitLabel.text = "\(textView.text.count)/200"
        delegate?.postPhoto(comment: textView.text)
    }
    
}
