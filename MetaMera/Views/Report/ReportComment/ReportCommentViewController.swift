//
//  ReportCommentViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/10/25.
//

import Foundation
import UIKit
import PKHUD

class ReportCommentViewController: UIViewController {
    
    
    @IBOutlet weak var reasonButton: UIButton!
    @IBOutlet weak var commentTextView: PlaceTextView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let reportModel = ReportModel()
    
    var postId: String!
    
    // メニュー表示項目
    //    enum MenuType: String {
    //        case spam = "スパム行為"
    //        case fraud = "詐欺、欺瞞行為"
    //        case bullying = "いじめ、嫌がらせ行為"
    //        case sexualHarassment = "セクハラ、性的行為"
    //        case violence = "暴力、危険な団体"
    //        case notLiking = "気に入らない"
    //    }
    //
    var selectedMenuType = MenuType.spam
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMenuButton()
        configView()
    }
    
    func configView(){
        reasonButton.setTitle(selectedMenuType.rawValue, for: .normal)
        commentTextView.placeHolder = "報告する理由を詳しく書いてください。"
        commentTextView.backgroundColor = UIColor.inputChatTextBackground
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        //spam
        actions.append(UIAction(title: MenuType.spam.rawValue, image: nil, state: self.selectedMenuType == MenuType.spam ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .spam
            self?.reasonButton.setTitle(MenuType.spam.rawValue, for: .normal)
            self?.configureMenuButton()
        }))
        //fraud
        actions.append(UIAction(title: MenuType.fraud.rawValue, image: nil, state: self.selectedMenuType == MenuType.fraud ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .fraud
            self?.reasonButton.setTitle(MenuType.fraud.rawValue, for: .normal)
            self?.configureMenuButton()
        }))
        //bullying
        actions.append(UIAction(title: MenuType.bullying.rawValue, image: nil, state: self.selectedMenuType == MenuType.bullying ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .bullying
            self?.reasonButton.setTitle(MenuType.bullying.rawValue, for: .normal)
            self?.configureMenuButton()
        }))
        //sexualHarassment
        actions.append(UIAction(title: MenuType.sexualHarassment.rawValue, image: nil, state: self.selectedMenuType == MenuType.sexualHarassment ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .sexualHarassment
            self?.reasonButton.setTitle(MenuType.sexualHarassment.rawValue, for: .normal)
            self?.configureMenuButton()
        }))
        //violence
        actions.append(UIAction(title: MenuType.violence.rawValue, image: nil, state: self.selectedMenuType == MenuType.violence ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .violence
            self?.reasonButton.setTitle(MenuType.violence.rawValue, for: .normal)
            self?.configureMenuButton()
        }))
        //notLiking
        actions.append(UIAction(title: MenuType.notLiking.rawValue, image: nil, state: self.selectedMenuType == MenuType.notLiking ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .notLiking
            self?.reasonButton.setTitle(MenuType.notLiking.rawValue, for: .normal)
            self?.configureMenuButton()
        }))
        
        // UIButtonにUIMenuを設定
        reasonButton.menu = UIMenu(title: "通報理由を選択してください。", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        reasonButton.showsMenuAsPrimaryAction = true
        // ボタンの表示を変更
        //        reasonButton.setTitle(self.selectedType.rawValue, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    var delegate : ReportProtocol?
    
    
    @IBAction func pushReportButton(_ sender: Any) {
        HUD.show(.progress, onView: view)
        reportModel.reportPost(reportItem: ReportItem(postId: postId,reportGenre: selectedMenuType.rawValue, uid: Profile.shared.loginUser.uid,comment: commentTextView.text)) {[weak self] result in
            switch result {
            case .success(_):
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self?.view, delay: 1) { (_) in
                        print("通報成功")
                        self?.navigationController?.popViewController(animated: true)
                        self?.delegate?.reportFinish(check: true)
                    }
                }
                break
            case .failure(let error):
                HUD.hide { (_) in
                    HUD.flash(.label(error.domain), delay: 1.0) { _ in
                        self?.navigationController?.popViewController(animated: true)
                        self?.delegate?.reportFinish(check: true)
                        print("通報失敗\(error)")
                    }
                }
                break
            }
        }
    }
    
}

protocol ReportProtocol:class {
    
    //    func catchData(count: Int)
    func reportFinish(check: Bool)
    
}
