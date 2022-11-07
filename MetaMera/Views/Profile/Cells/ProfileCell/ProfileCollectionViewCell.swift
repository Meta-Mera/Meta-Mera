//
//  ProfileCollectionViewCell.swift
//  MetaMera
//
//  Created by 三橋史明 on 2022/11/07.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(_ num: Int) {
        numberLabel.text = String(num)
    }

}
