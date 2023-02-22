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
    var type: SettingType
    
    enum SettingType {
        case emailAddressSettings
        case changePassword
        case notificationSettings
        case contact
        case withdrawalFromMetaMera
        case appInfo
    }
}

final class SettingModel {
    let items: [SettingItem] = [
        //Email Settings
        .init(title:LocalizeKey.emailAddressSettings.localizedString(),
              description: LocalizeKey.emailAddressSettingsDescription.localizedString(), type: .emailAddressSettings),
        
        //Change Password
        .init(title: LocalizeKey.changePassword.localizedString(),
              description: LocalizeKey.changePasswordDescription.localizedString(), type: .changePassword),
        
        //Notification
        .init(title: LocalizeKey.notificationSettings.localizedString(),
              description: LocalizeKey.notificationSettingsDescription.localizedString(), type: .notificationSettings),
        
        //Contact
        .init(title: LocalizeKey.contact.localizedString(),
              description: LocalizeKey.contactDescription.localizedString(), type: .contact),
        
        //appInfo
        .init(title: LocalizeKey.appInfo.localizedString(),
              description: LocalizeKey.appInfoDescription.localizedString(), type: .withdrawalFromMetaMera),
        
        //Withdrawal
        .init(title: LocalizeKey.withdrawalFromMetaMera.localizedString(),
              description: LocalizeKey.withdrawalFromMetaMeraDescription.localizedString(), type: .withdrawalFromMetaMera),
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
        tableView.backgroundColor = UIColor.clear
        tableView.isScrollEnabled = false
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
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

extension AdvanceSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected", indexPath.row)
//
//        let item = items[indexPath]
//
//        switch item. {
//
//        }
        
        switch indexPath.row {
        case 0:
            Goto.ChangeEmailAddressViewController(view: self)
            break
        case 1:
            Goto.ChangePasswordViewController(view: self)
            break
        case 2:
            if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.canOpenURL(settingURL)
                UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
            }
            break
        case 3:
            Goto.ContactViewController(view: self)
            break
        case 4:
            let vc = MetaMera.AppInfoViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 5:
            Goto.WithdrawalViewController(view: self)
            break
        default:
            self.navigationController?.popViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
