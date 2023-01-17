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
        check()
        TESTautoLogin()
        #endif

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func maintenanceCheck(completion: ((Bool,String, String) -> Void)? = nil){
        RemoteConfigClient.shared.fetchServerMaintenanceConfig(
            succeeded: { [weak self] config in
                self?.maintenance = config.isUnderMaintenance
                completion?(config.isUnderMaintenance,config.title,config.message)
            }, failed: { [weak self] errorMessage in
            }
        )
    }
    
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
        let alert = AlartManager.shared.setting(
            title: "新規登録一時停止中",
            message: "大変申し訳ありませんが、ただいま一時的に新規登録を停止させていただいております。再開までもうしばらくお待ちください。",
            style: .alert,
            actions: [defaultAction]
        )
        check{[weak self] isMaintenance in
            if !isMaintenance {
                self?.createAccountCheck { [weak self] limitCheck in
                    if(!(self?.maintenance ?? true) && (self?.createAccountBool ?? false) && !limitCheck){
                        
                        if (self?.firstCheck ?? true){
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
                                self?.firstCheck = false
                            }
                        }else{
                            if let me = self {
                                Goto.SignUp(view: me)
                            }
                        }
                    }
                    if (!(self?.createAccountBool ?? false) || limitCheck || (self?.maintenance ?? true)){
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
        

        
    }
    @objc func PushSignIn(_ sender: Any) {
        check{[weak self] isMaintenance in
            if !isMaintenance {
                self?.autoLogin()
            }
        }
    }
    
    func createAccount(completion: ((Bool) -> Void)? = nil) {
        var counter : Int = 10000
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
    
    func createAccountCheck(completion: ((Bool) -> Void)? = nil){
        RemoteConfigClient.shared.fetchRestrictionsConfig(
            succeeded: { [weak self] config in
                self?.remoteConfigBool = config.newRegistrationRestrictions
                self?.remoteConfigLimit = config.limit
                completion?(config.newRegistrationRestrictions)
            }, failed: { errorMessage in
            }
        )
    }
    
//    var authListener
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self)
    }
    
    func TESTautoLogin(){
        check()
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
                Goto.SignIn(view: self ?? TopViewController())
            }
        }
    }
    
}
