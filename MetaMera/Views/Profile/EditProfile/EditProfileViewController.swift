//
//  EditProfileViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/11/16.
//

import UIKit
import Firebase
import Photos
import Alamofire
import AlamofireImage

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var selectHeaderPhotoButton: UIButton!
    @IBOutlet weak var selectIconPhotoButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var bioTextField: PlaceTextView!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var userNameLimitLabel: UILabel!
    
    private let user: User
    
    // image
    private var imagePicker = UIImagePickerController()
    private var userImage = UIImage()
    private var changeProfileImage: Bool = false
    
    let accessory = Accessory()
    
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        setupProfileData()
        
        // Do any additional setup after loading the view.
    }
    
    func configView(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        bioTextField.delegate = self
        userNameTextField.delegate = self
        limitLabel.text = ""
        userNameLimitLabel.text = ""
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        if user.bio.isEmpty {
            bioTextField.placeHolder = LocalizeKey.bio.localizedString()
        }
    }

    
    //画面から離れたとき
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let bio = bioTextField.text,
              let userName = userNameTextField.text else {
            print("更新情報の取得に失敗しました。")
            return
        }
        
        if(changeProfileImage){
            saveFirebaseStorage(image: userImage)
        }
        
        Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid).updateData([
            "bio": bio,
            "userName": userName
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("ユーザー情報の更新に成功しました。")
                
                Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid).getDocument { (userSnapshot, error) in
                    if let error = error {
                        print("ユーザー情報の取得に失敗しました。\(error)")
                        return
                    }
                    guard let dic = userSnapshot?.data() else { return }
                    let user = User(dic: dic,uid: Profile.shared.loginUser.uid)
                    Profile.shared.loginUser = user
                    
                }
            }
        }
        
    }
    
    //ユーザープロフィールデータを表示
    private func setupProfileData() {
        bioTextField.text = user.bio
        userNameTextField.text = user.userName
        if let userIconImageURL = URL(string: user.profileImage) {
            userIconImageView.af.setImage(withURL: userIconImageURL)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        let preNC = self.navigationController!
        let preVC = preNC.viewControllers[preNC.viewControllers.count - 2] as! ProfileViewController
        if(changeProfileImage){
            preVC.userIconImageView.setImage(image: userImage, name: "")
        }
        preVC.userNameLabel.text = userNameTextField.text
        preVC.discriptionLabel.text = bioTextField.text
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushMenuButton(_ sender: Any) {
        
    }
    
    @IBAction func pushChangeIcoonButton(_ sender: Any) {
        print("アイコン変更したいよ")
        accessory.openPhotoLibrary(view: self, imagePicker: imagePicker)
        print("slect image")
    }
    
    
    func saveFirebaseStorage(image: UIImage){
        accessory.saveToFireStorege(selectedImage: image, fileName: Profile.shared.loginUser.uid+".jpeg", folderName: "profile") { [weak self] result in
            switch result {
            case .success((let urlString, let returnImage)):
                self?.updateProfileImageToFirestore(profileImageUrl: urlString, image: returnImage)
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    func updateProfileImageToFirestore(profileImageUrl: String, image: UIImage){
        //        Firestore.firestore().document("users").collection(Profile.shared.userId).value(forKey: "")
        let doc = Firestore.firestore().collection("Users").document(Profile.shared.loginUser.uid)
        doc.updateData([
            "profileImage" : profileImageUrl]
        ) { err in
            if let err = err {
                print("firestoreの更新に失敗\(err)")
                return
            }
            print("更新成功")
            
        }
    }
    
    
}

extension EditProfileViewController: UITextViewDelegate {
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        return textView.text.count + (text.count - range.length) <= 50
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.limitLabel.text = "\(textView.text.count)/50"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: .newlines)//既に存在する改行数
        let newLines = text.components(separatedBy: .newlines)//新規改行数
        let linesAfterChange = existingLines.count + newLines.count - 1 //最終改行数。-1は編集したら必ず1改行としてカウントされるから。
        return linesAfterChange <= 4 && textView.text.count + (text.count - range.length) <= 50
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.limitLabel.text = "\(textView.text.count)/50"
    }

    
}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let userName = userNameTextField.text else { return }
        self.userNameLimitLabel.text = "\(userName.count)/30"

        if userName.count > 30 {
            userNameTextField.text = String(userName.prefix(30))
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            userIconImageView.setImage(image: editImage, name: "")
            userImage = editImage
            changeProfileImage = true
        }else if let originalImage = info[.originalImage] as? UIImage {
            userIconImageView.setImage(image: originalImage, name: "")
            userImage = originalImage
            changeProfileImage = true
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePicker closed")
        dismiss(animated: true)
        
    }
    
}
