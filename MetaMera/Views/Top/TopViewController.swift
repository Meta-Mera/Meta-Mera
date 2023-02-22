//
//  TopViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/10.
//

import UIKit
import ARKit
import RealityKit
import Firebase

class TopViewController: UIViewController {
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signInImageView: UIImageView!
    @IBOutlet weak var signUpImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    
    let signInModel = SignInModel()
    let alertModel = AlertModel()
    
    var maintenance = false
    var createAccountBool = true
    var remoteConfigBool = false
    var remoteConfigLimit = 100
    var firstCheck = true
    var newest = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewConfig()
    }
    
    func viewConfig(){
        signUpImageView.isUserInteractionEnabled = true
        signUpImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignUp)))
        
        
        signInImageView.isUserInteractionEnabled = true
        signInImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PushSignIn)))
        
        
        UIView.animate(withDuration: 1.0,
                       delay: 0.5,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { () in
            self.logoImageView.center.y -= 100.0
            
        }, completion: { (Bool) in
            //self.logoImageView.center.y -= 50.0
            //self.logoImageView.layer.position = CGPoint(x:0, y:100)
            self.signInImageView.isHidden = false
            self.signUpImageView.isHidden = false
            self.signInImageView.alpha = 0
            self.signUpImageView.alpha = 0
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () in
//                self.logoImageView.center.y -= 20.0
                self.signInImageView.center.y -= 50.0
                self.signInImageView.alpha += 0.7
                
                self.signUpImageView.center.y -= 50.0
                self.signUpImageView.alpha += 0.7
                
            }, completion: { (Bool) in
                
            })
        })
        
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = "Ver: \(version)"
        } else {
            versionLabel.text = "Ver: unknown"
        }
        
        #if RELEASE
//        updateCheck{[weak self] result in
//            if !result {
//                self?.check()
//            }
//        }
        TESTautoLogin()
        #endif

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    /// RemoteConfigからメンテナンス状態を取得します。
    /// - Parameter completion: メンテナンス状態, タイトル, メッセージ を返します。
    func maintenanceCheck(completion: ((Bool,String, String) -> Void)? = nil){
        RemoteConfigClient.shared.fetchServerMaintenanceConfig(
            succeeded: { [weak self] config in
                //RemoteConfigから取得ができた場合
                
                //メンテナンス状態をmaintenanceに入れる
                self?.maintenance = config.isUnderMaintenance
                
                //取得してきたデータをそのまま返す
                completion?(config.isUnderMaintenance,config.title,config.message)
            }, failed: { errorMessage in
                //RemoteConfigから情報が取得できなかった場合
            }
        )
    }
    
    /// メンテナンス状態を確認してメンテナンス中であればアラートを表示します。
    /// - Parameter completion: メンテナンス状態をBool値で返します。
    func check(completion: ((Bool) -> Void)? = nil){
        maintenanceCheck {[weak self] isMaintenance,title,message in
            self?.maintenance = isMaintenance
            if isMaintenance {
                let defaultAction = UIAlertAction(
                    title: "閉じる",
                    style: .default) { Void in
                        self?.maintenanceCheck()
                    }
                let alert = AlartManager.shared.setting(
                    title: title,
                    message: message,
                    style: .alert,
                    actions: [defaultAction]
                )
                self?.present(alert, animated: true, completion: nil)
                
            }
            completion?(isMaintenance)
        }
    }

    
    @objc func PushSignUp(_ sender: Any) {
        let defaultAction = UIAlertAction(
            title: "閉じる",
            style: .default
        )
        let updateAlert = AlartManager.shared.setting(
            title: "お知らせ",
            message: "最新のバージョンが存在しています。\n至急、バージョンアップをお願いします。",
            style: .alert,
            actions: [defaultAction]
        )
        updateCheck{ [weak self] result in
            if result {
                self?.present(updateAlert, animated: true)
                return
            }else {
                let alert = AlartManager.shared.setting(
                    title: "新規登録一時停止中",
                    message: "大変申し訳ありませんが、ただいま一時的に新規登録を停止させていただいております。再開までもうしばらくお待ちください。",
                    style: .alert,
                    actions: [defaultAction]
                )
                self?.check{[weak self] isMaintenance in
                    if !isMaintenance {//メンテナンス中ではない
                        self?.createAccountCheck { [weak self] limitCheck in
                            if(!(self?.maintenance ?? true) && (self?.createAccountBool ?? false) && !limitCheck){
                                //メンテナンス中でなく、新規登録も許可されていて、制限未満の場合
                                if (self?.firstCheck ?? true){//初回チェック
                                    self?.createAccount { [weak self] isCountRange in
                                        if let me = self, isCountRange {
                                            // アカウント作成可
                                            // サインアップへ遷移
                                            Goto.SignUp(view: me)
                                        }else {
                                            // アカウント作成不可
                                            // アラート表示
                                            self?.present(alert, animated: true)
                                        }
                                        self?.firstCheck = false //次からはFirestoreへユーザー数を取得しない
                                    }
                                }else{//2回目移行
                                    if let me = self {
                                        // サインアップへ遷移
                                        Goto.SignUp(view: me)
                                    }
                                }
                            }
                            if (!(self?.createAccountBool ?? false) || limitCheck || (self?.maintenance ?? true)){
                                //新規登録できないことをユーザーに表示
                                self?.present(alert, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func PushSignIn(_ sender: Any) {
        let defaultAction = UIAlertAction(
            title: "閉じる",
            style: .default
        )
        let alert = AlartManager.shared.setting(
            title: "お知らせ",
            message: "最新のバージョンが存在しています。\n至急、バージョンアップをお願いします。",
            style: .alert,
            actions: [defaultAction]
        )
        updateCheck{ [weak self] result in
            if result {
                self?.present(alert, animated: true)
                return
            }else {
                self?.check{ isMaintenance in
                    if !isMaintenance {
                        self?.autoLogin()
                    }
                }
            }
        }
    }
    
    /// Firestoreから現在のユーザー数を取得して新規登録して良いのかを確認します。
    /// - Parameter completion: 新規登録をして良いかBool値で返します。
    func createAccount(completion: ((Bool) -> Void)? = nil) {
        var counter : Int = 10000 //もし値が取れなかった用
        FirebaseManager.user.ref.document("Counter").getDocument {[weak self] snapshot, error in
            if let error = error {
                print("管理データの取得に失敗\(error)")
            }
            guard let dic = snapshot?.data() else { return }
            let data  = User(dic: dic, uid: "Counter")
            counter = data.limited
            let isCountRange = counter < self?.remoteConfigLimit ?? 100
            self?.createAccountBool = isCountRange
            completion?(isCountRange)
        }
    }
    
    /// 新規登録をして良いかRemoteConfigから取得します。
    /// - Parameter completion: 新規登録をして良いかをBool値で返します。
    func createAccountCheck(completion: ((Bool) -> Void)? = nil){
        RemoteConfigClient.shared.fetchRestrictionsConfig(
            succeeded: { [weak self] config in
                //RemoteConfigから情報の取得に成功
                
                //新規登録をして良いかをBool値で入れる。
                self?.remoteConfigBool = config.newRegistrationRestrictions
                //ユーザー制限数を入れる
                self?.remoteConfigLimit = config.limit
                //新規登録をして良いかをBool値で返します。
                completion?(config.newRegistrationRestrictions)
            }, failed: { errorMessage in
                //RemoteConfigから情報の取得に失敗
            }
        )
    }
    
    /// 最新のバージョンか確認します。
    /// - Parameter completion: アップデートが必要ならtrueを返します。
    func updateCheck(completion: ((Bool) -> Void)? = nil){
        let localVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        RemoteConfigClient.shared.fetchUpdateInfoConfig(
            succeeded: { [weak self] config in
                if config.updateInfo {
                    self?.newest = localVersionString != config.current_version
                    completion?(localVersionString != config.current_version)
                }else{
                    completion?(false)
                }
            },failed: { [weak self] errorMessage in
                self?.newest = false
                completion?(true)
            }
        )
    }
    
//    var authListener
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self)
    }
    
    func TESTautoLogin(){
        let defaultAction = UIAlertAction(
            title: "閉じる",
            style: .default
        )
        let alert = AlartManager.shared.setting(
            title: "お知らせ",
            message: "最新のバージョンが存在しています。\n至急、バージョンアップをお願いします。",
            style: .alert,
            actions: [defaultAction]
        )
        updateCheck{ [weak self] result in
            if result {
                self?.present(alert, animated: true, completion: nil)
            }else {
                self?.check{ isMaintenance in
                    if !isMaintenance {
                        Auth.auth().addStateDidChangeListener {[weak self] auth, user in
                            if user != nil{
                                DispatchQueue.main.async {
                                    self?.signInModel.signIn(user: user!) {result in
                                        switch result{
                                        case .success(_): //Sign in 成功
                                            Goto.ARView(view: self!)
                                            break
                                        case .failure(_): //Sign in 失敗
                                            break
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func autoLogin(){
        //TODO: imageViewをbuttonに変更してtapしたら無効化させること
        Auth.auth().addStateDidChangeListener {[weak self] auth, user in
            if user != nil{
                DispatchQueue.main.async {
                    self?.signInModel.signIn(user: user!) {result in
                        switch result{
                        case .success(_): //Sign in 成功
                            Goto.ARView(view: self!)
                            break
                        case .failure(_): //Sign in 失敗
                            Goto.SignIn(view: self!)
                            break
                        }
                        
                    }
                }
            }else{
                Goto.SignIn(view: self!)
            }
        }
    }
    
}
