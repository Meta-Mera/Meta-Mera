//
//  CreateAccountViewController.swift
//  MetaMera
//
//  Created by admin on 2022/11/08.
//

import UIKit
import PKHUD
import Photos
import Firebase

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var photoMarkButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    let password: String
    let confirmPassword: String
    let eMail: String
    var userName: String {
        didSet {
            userNameTextField.text = userName
        }
    }
    
    let signUpModel = SignUpModel()
    let accessory = Accessory()
    
    // image
    private var imagePicker = UIImagePickerController()
    private var userImage = UIImage()
    private var changeProfileImage: Bool = false
    private var userIconURL: String = "https://firebasestorage.googleapis.com/v0/b/metamera-e2b4b.appspot.com/o/profile%2FIcon.png?alt=media&token=e39273e4-d638-4318-ab45-1e0d97b4c03c"
    
    init(password: String, confirmPassword: String, eMail: String, userName: String) {
        self.password = password
        self.confirmPassword = confirmPassword
        self.eMail = eMail
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        userNameTextField.delegate = self
        userNameTextField.text = userName
        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2
        self.navigationItem.hidesBackButton = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func pushNextButton(_ sender: Any) {
        handleAuthToFirebase()
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushPhotoButton(_ sender: Any) {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized:
                    print("許可ずみ")
                    break
                case .limited:
                    print("制限あり")
                    break
                case .denied:
                    print("拒否ずみ")
                    break
                default:
                    break
                }
            }
        }else  {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        print("許可ずみ")
                    } else if status == .denied {
                        print("拒否ずみ")
                    }
                }
            } else {
                
            }
        }
        
        
        // 権限
        let authPhotoLibraryStatus = PHPhotoLibrary.authorizationStatus()
        // authPhotoLibraryStatus = .authorized : 許可
        //                        = .limited    : 選択した画像のみ
        //                        = .denied     : 拒否
        
        if authPhotoLibraryStatus == .limited {
            
            //アラートの設定
            let alert = UIAlertController(title: "Failed to save image", message: "Allow this app to access Photos.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Enable photos access", style: .default) { (action) in
                //設定を開く
                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.canOpenURL(settingURL)
                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (acrion) in
                self.dismiss(animated: true, completion: nil)
            }
            
            //アラートの下にあるボタンを追加
            alert.addAction(cancel)
            alert.addAction(ok)
            //アラートの表示
            present(alert, animated: true, completion: nil)
            
            
        }
        if authPhotoLibraryStatus == .denied {
            
            //アラートの設定
            let alert = UIAlertController(title: "Failed to save image", message: "Allow this app to access Photos.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Enable photos access", style: .default) { (action) in
                //設定を開く
                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.canOpenURL(settingURL)
                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (acrion) in
                self.dismiss(animated: true, completion: nil)
            }
            
            //アラートの下にあるボタンを追加
            alert.addAction(cancel)
            alert.addAction(ok)
            //アラートの表示
            present(alert, animated: true, completion: nil)
        }
        // fix/update_prof_image_#33 >>>
        if authPhotoLibraryStatus == .authorized {
            // <<<
            present(imagePicker, animated: true)    // カメラロール起動
        }
        print("slect image")
    }
    
    
    
    //Firebase登録処理
    private func handleAuthToFirebase(){
        HUD.show(.progress, onView: view)
        
        
        signUpModel.signUp(signUpItem: .init(email: eMail, password: password, confirmPassword: confirmPassword, bio: "", userName: userNameTextField.text, userIconURL : userIconURL)) { [weak self] result in
            switch result {
                
            case .success(let user): //Sign up 成功
                
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self?.view, delay: 1) { [weak self] (_) in
                        Profile.shared.loginUser = user
                        Profile.shared.isLogin = true
                        if(self!.changeProfileImage){
                            self?.saveFirebaseStorage(image: self!.userImage)
                        }
                        self?.presentToARViewController()
                    }
                }
            case .failure(let error): //Sign up 失敗
                
                HUD.hide { (_) in
                    HUD.flash(.label(error.domain), delay: 1.0) { _ in
                        print(error)
                    }
                }
            }
        }
    }
    
    //問題なく登録できた際、 Main画面に遷移
    private func presentToARViewController(){
//        let storyBoard = UIStoryboard(name: "ARViewController", bundle: nil)
//        let homeViewController = storyBoard.instantiateViewController(identifier: "ARViewController") as! ARViewController
//        homeViewController.modalPresentationStyle = .fullScreen
//        self.present(homeViewController, animated: true, completion: nil)
//
        if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "ARViewController", bundle: .main))() as? ARViewController {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
    
    func saveFirebaseStorage(image: UIImage){
        accessory.saveToFireStorege(selectedImage: image, fileName: Profile.shared.loginUser.uid+".jpeg", folderName: "profile") { [weak self] result in
            switch result {
            case .success((let urlString, _)):
                self?.userIconURL = urlString
                self?.accessory.updateProfileImageToFirestore(profileImageUrl: urlString)
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            iconImageView.setImage(image: editImage, name: "")
            userImage = editImage
            changeProfileImage = true
        }else if let originalImage = info[.originalImage] as? UIImage {
            iconImageView.setImage(image: originalImage, name: "")
            userImage = originalImage
            changeProfileImage = true
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        
    }
}
