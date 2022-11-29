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
        .init(title: "メールアドレスの設定", description: "現在登録されているメールアドレスの確認と変更をすることができます。"),
        .init(title: "パスワードの変更", description: "現在登録しているパスワードを変更することができます。"),
        .init(title: "通知設定", description: "通知の種類を設定することができます。"),
        .init(title: "お問い合わせ", description: "何かお困りのことがある場合やバグの修正依頼などお気軽にお問合わせください。"),
        .init(title: "退会", description: "Meta-Meraのアカウントを削除し退会する手続きを行います。"),
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
    }
}
