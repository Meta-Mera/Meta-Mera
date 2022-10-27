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
    
    var maintenance = false
    
    
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
        #endif

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
#if RELEASE
        check()
#endif
    }
    
    
    func check(){
        RemoteConfigClient.shared.fetchServerMaintenanceConfig(
            succeeded: { [weak self] config in
                self?.maintenance = config.isUnderMaintenance
                if config.isUnderMaintenance {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let `self` = self else { return }
                        let alert: UIAlertController = UIAlertController(title: config.title, message: config.message, preferredStyle:  UIAlertController.Style.alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "Reload", style: UIAlertAction.Style.default, handler:{
                            // ボタンが押された時の処理を書く（クロージャ実装）
                            (action: UIAlertAction!) -> Void in
                            self.check()
                        })
                        
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }, failed: { [weak self] errorMessage in
            }
        )
    }

    
    @objc func PushSignUp(_ sender: Any) {
        if(!maintenance){
            Goto.SignUp(view: self)
        }

        
    }
    @objc func PushSignIn(_ sender: Any) {
        if(!maintenance){
            autoLogin()
        }
    }
    
//    var authListener
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self)
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
