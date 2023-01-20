//
//  AdvanceSettingTableViewCell.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/11/25.
//

import UIKit

class AdvanceSettingTableViewCell: UITableViewCell {
    
    // TODO: .swiftとつなぐ
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ item: SettingItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
    
}
