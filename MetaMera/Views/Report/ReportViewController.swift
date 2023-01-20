//
//  ReportViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/10/24.
//

import Foundation
import UIKit

class ReportViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //スパムボタン
    @IBOutlet weak var spamButton: UIButton!
    //詐欺ボタン
    @IBOutlet weak var fraudButton: UIButton!
    //いじめボタン
    @IBOutlet weak var bullyingButton: UIButton!
    //セクハラボタン
    @IBOutlet weak var sexualHarassmentButton: UIButton!
    //暴力ボタン
    @IBOutlet weak var violenceButton: UIButton!
    //気に入らない
    @IBOutlet weak var notLikingButton: UIButton!
    
    var postId: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    //MARK: 前の画面に戻る
    @IBAction func pushBackButton(_ sender: Any) {
        print("push back image")
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 各ボタンを押したら詳細画面へ移行する
    @IBAction func pushSpamButton(_ sender: UIButton) {
        gotoReport(tag: .spam)
    }
    
    @IBAction func pushFraudButton(_ sender: UIButton) {
        gotoReport(tag: .fraud)
    }
    
    @IBAction func pushBullyingButton(_ sender: UIButton) {
        gotoReport(tag: .bullying)
    }
    
    @IBAction func pusShexualHarassmentButton(_ sender: UIButton) {
        gotoReport(tag: .sexualHarassment)
    }
    
    @IBAction func pushViolenceButton(_ sender: UIButton) {
        gotoReport(tag: .violence)
    }
    
    @IBAction func pushNotLikingButton(_ sender: UIButton) {
        gotoReport(tag: .notLiking)
    }
    
    func gotoReport(tag: MenuType){
        print("Goto-ReportCommentView was called.")
        let vc = UIStoryboard(name: "ReportCommentViewController", bundle: nil).instantiateViewController(withIdentifier: "ReportCommentViewController") as! ReportCommentViewController
        vc.modalPresentationStyle = .fullScreen
        vc.postId = postId
        vc.selectedMenuType = tag
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: 各ボタンを押したら詳細画面へ移行する -
}
extension ReportViewController: ReportProtocol {
    
    func reportFinish(check: Bool) {
        let finishCheck = check
        print("よばれたよ！！！！！！！！！！")
        if finishCheck {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
