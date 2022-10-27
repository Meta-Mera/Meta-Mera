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
        setSwipeBack()
        reasonButton.setTitle(NSLocalizedString(selectedMenuType.rawValue, comment: ""), for: .normal)
        commentTextView.placeHolder = LocalizeKey.reportReason.localizedString()
        commentTextView.backgroundColor = UIColor.inputChatTextBackground
        reportButton.backgroundColor = UIColor.normalButtonBackground()
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        //spam
        actions.append(UIAction(title: LocalizeKey.spam.localizedString(), image: nil, state: self.selectedMenuType == MenuType.spam ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .spam
            self?.reasonButton.setTitle(LocalizeKey.spam.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //fraud
        actions.append(UIAction(title: LocalizeKey.fraud.localizedString(), image: nil, state: self.selectedMenuType == MenuType.fraud ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .fraud
            self?.reasonButton.setTitle(LocalizeKey.fraud.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //bullying
        actions.append(UIAction(title: LocalizeKey.bullying.localizedString(), image: nil, state: self.selectedMenuType == MenuType.bullying ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .bullying
            self?.reasonButton.setTitle(LocalizeKey.bullying.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //sexualHarassment
        actions.append(UIAction(title: LocalizeKey.sexualHarassment.localizedString(), image: nil, state: self.selectedMenuType == MenuType.sexualHarassment ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .sexualHarassment
            self?.reasonButton.setTitle(LocalizeKey.sexualHarassment.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //violence
        actions.append(UIAction(title: LocalizeKey.violence.localizedString(), image: nil, state: self.selectedMenuType == MenuType.violence ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .violence
            self?.reasonButton.setTitle(LocalizeKey.violence.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //notLiking
        actions.append(UIAction(title: LocalizeKey.notLiking.localizedString(), image: nil, state: self.selectedMenuType == MenuType.notLiking ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .notLiking
            self?.reasonButton.setTitle(LocalizeKey.notLiking.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        
        // UIButtonにUIMenuを設定
        reasonButton.menu = UIMenu(title: LocalizeKey.selectReportReason.localizedString(), options: .displayInline, children: actions)
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
