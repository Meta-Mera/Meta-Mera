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
                if config.isUnderMaintenance {
                    self?.maintenance = config.isUnderMaintenance
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let `self` = self else { return }
                        let alert: UIAlertController = UIAlertController(title: config.title, message: config.message, preferredStyle:  UIAlertController.Style.alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "再読み込み", style: UIAlertAction.Style.default, handler:{
                            // ボタンが押された時の処理を書く（クロージャ実装）
                            (action: UIAlertAction!) -> Void in
                            self.check()
                        })
                        
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                } else{
                    self?.maintenance = config.isUnderMaintenance
                }
            }, failed: { [weak self] errorMessage in
            }
        )
    }

    
    @objc func PushSignUp(_ sender: Any) {
        if(!maintenance){
            Goto.SignUp(view: self)
        }
        
//        Auth.auth().signIn(withEmail: "g019c1045@g.neec.ac.jp", password: "123456") { res, err in
//            if let err = err {
//                print("ログイン情報の取得に失敗",err)
//                return
//            }
//            guard let uid = Auth.auth().currentUser?.uid else { return }
//            Firestore.firestore().collection("Users").document(uid).getDocument { (userSnapshot, err) in
//                if let err = err {
//                    print("ユーザー情報の取得に失敗しました。\(err)")
//                    return
//                }
//
//                guard let dic = userSnapshot?.data() else { return }
//                let user = User(dic: dic,uid: uid)
//                Profile.shared.loginUser = user
//                switch Profile.shared.updateProfileImage() {
//                case .success(_):
//                    print("画像あるらしいよ: ",user.profileImage,"+",uid)
//                    break
//                case .failure(_):
//                    print("画像保存されてないよ〜: ",user.profileImage,"+",uid)
//                    Profile.shared.saveImageToDevice(image: user.profileImage, fileName: uid)
//                    break
//                }
//                Firestore.firestore().collection("Posts").document("Uz93q4hTLBHvLUFglhxp").getDocument { (snapshot, err) in
//                    if let err = err {
//                        print("投稿情報の取得に失敗しました。\(err)")
//                        return
//                    }
//
//                    guard let dic = snapshot?.data() else { return }
//                    print("投稿情報の取得に成功しました。")
//                    let post = Post(dic: dic,postId: "Uz93q4hTLBHvLUFglhxp")
//                    print(post.createdAt.dateValue())
//                    Goto.ChatRoomView(view: self, image: UIImage(named: "katsu")!, post: post)
//                }
//            }
//        }
        
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
//            Auth.auth().removeStateDidChangeListener(self!)
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
