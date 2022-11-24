//
//  EditProfileViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/11/16.
//

import UIKit
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
    
    private let user: User
    
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
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        if user.bio.isEmpty {
            bioTextField.placeHolder = LocalizeKey.bio.localizedString()
        }
    }
    
    //ユーザープロフィールデータを表示
    private func setupProfileData() {
        userNameTextField.text = user.userName
        bioTextField.text = user.bio
        if let userIconImageURL = URL(string: user.profileImage) {
            userIconImageView.af.setImage(withURL: userIconImageURL)
        }
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushMenuButton(_ sender: Any) {
        
    }
    
    @IBAction func pushChangeIcoonButton(_ sender: Any) {
        print("アイコン変更したいよ")
    }
    

}
