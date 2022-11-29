//
//  AdvanceSettingViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/11/25.
//

import UIKit

public struct SettingItem {
    var title: String
    var description: String
}

final class SettingModel {
    let items: [SettingItem] = [
        //Email Settings
        .init(title:LocalizeKey.emailAddressSettings.localizedString(),
              description: LocalizeKey.emailAddressSettingsDescription.localizedString()),
        
        //Change Password
        .init(title: LocalizeKey.changePassword.localizedString(),
              description: LocalizeKey.changePasswordDescription.localizedString()),
        
        //Contact
        .init(title: LocalizeKey.notificationSettings.localizedString(),
              description: LocalizeKey.notificationSettingsDescription.localizedString()),
        
        //Contact
        .init(title: LocalizeKey.contact.localizedString(),
              description: LocalizeKey.contactDescription.localizedString()),
        
        //Withdrawal
        .init(title: LocalizeKey.withdrawalFromMetaMera.localizedString(),
              description: LocalizeKey.withdrawalFromMetaMeraDescription.localizedString()),
    ]
}

class AdvanceSettingViewController: UIViewController {
    
    private lazy var items: [SettingItem] = {
        let model = SettingModel()
        let items = model.items
        return items
    }()
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var optionButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(.init(nibName: "AdvanceSettingTableViewCell", bundle: .main), forCellReuseIdentifier: "AdvanceSettingTableViewCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AdvanceSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdvanceSettingTableViewCell") as? AdvanceSettingTableViewCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.bind(item)
        return cell
    }
}

extension AdvanceSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected", indexPath.row)
    }
}
