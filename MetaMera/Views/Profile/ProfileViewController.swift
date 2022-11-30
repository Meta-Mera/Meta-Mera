//
//  ProfileViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/22.
//

import ARCL
import UIKit
import MapKit
import PKHUD
import Photos
import AVFoundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoImageButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    private let user: User
    private var itsMe: Bool
    
    init(user: User, itsMe: Bool) {
        self.user = user
        self.itsMe = itsMe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        setupProfileData()
        getUserPostData()
//        getUserFavoriteData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configCollectonViewLayout()
    }
    
    // 画面レイアウト
    private func configView() {
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        
        if user.uid != Profile.shared.loginUser.uid {
            mapButton.isHidden = true
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
        // collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "ProfileCollectionViewCell")
        collectionView.register(UINib(nibName: "MapViewCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "MapViewCollectionViewCell")
        collectionView.register(UINib(nibName: "PhotosCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "PhotosCollectionViewCell")
        
        updateMenuButtonLayout(type: .photo)
    }
    
    private func configCollectonViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: view.bounds.width, height: collectionView.bounds.height)
        layout.minimumInteritemSpacing = .zero
        layout.minimumLineSpacing = .zero
        layout.sectionInset = .zero
        layout.invalidateLayout()
        collectionView.collectionViewLayout = layout
    }
    
    /// ユーザープロフィールデータを表示
    private func setupProfileData() {
        print("\(user.userName) : if ",itsMe)
        if(itsMe){
            userNameLabel.text = Profile.shared.loginUser.userName
            discriptionLabel.text = Profile.shared.loginUser.bio
            if let userIconImageURL = URL(string: Profile.shared.loginUser.profileImage) {
                userIconImageView.af.setImage(withURL: userIconImageURL)
            }
        }else {
            userNameLabel.text = user.userName
            discriptionLabel.text = user.bio
            if let userIconImageURL = URL(string: user.profileImage) {
                userIconImageView.af.setImage(withURL: userIconImageURL)
            }
        }
//        collectionView.reloadData()
    }

    // MARK: Action Buttons
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        if itsMe {
            
            let alertSheet = UIAlertController(title: "Option", message: "What happened?", preferredStyle: UIAlertController.Style.actionSheet)
            
            // アクションを追加.
            
            let profileEdit = UIAlertAction(title: LocalizeKey.accountSetting.localizedString(), style: UIAlertAction.Style.default, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                Goto.EditProfileViewController(user: Profile.shared.loginUser, view: self!)
            })
            
            let advanceSetting = UIAlertAction(title: LocalizeKey.advanceSetting.localizedString(), style: UIAlertAction.Style.default, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                Goto.AdvanceSettingViewController(view: self!)
            })
            
            let signOut = UIAlertAction(title: LocalizeKey.signOut.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
                (action: UIAlertAction!) in
                self?.pushSignOut()
            })
            
            let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: UIAlertAction.Style.cancel, handler: {
                (action: UIAlertAction!) in
            })
            
            alertSheet.addAction(profileEdit)
            alertSheet.addAction(advanceSetting)
            alertSheet.addAction(signOut)
            alertSheet.addAction(cancel)
            
            self.present(alertSheet, animated: true, completion: nil)
            
        }else {
            let alertSheet = UIAlertController(title: "Option", message: "What happened?", preferredStyle: UIAlertController.Style.actionSheet)
            
            // アクションを追加.
            
            let block = UIAlertAction(title: LocalizeKey.block.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                print("Block")
            })
            
            let report = UIAlertAction(title: LocalizeKey.report.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
                (action: UIAlertAction!) -> Void in
                print("Report")
            })
            
            let signOut = UIAlertAction(title: LocalizeKey.signOut.localizedString(), style: UIAlertAction.Style.destructive, handler: {
                (action: UIAlertAction!) in
            })
            
            let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: UIAlertAction.Style.cancel, handler: {
                (action: UIAlertAction!) in
            })
            
            alertSheet.addAction(block)
            alertSheet.addAction(report)
            alertSheet.addAction(signOut)
            alertSheet.addAction(cancel)
            
            self.present(alertSheet, animated: true, completion: nil)
        }
    }
    
    func pushSignOut(){
        do {
            try Auth.auth().signOut()
            Profile.shared.isLogin = false
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // CollectionView選択時動作
    //マップボタン押したら濃くなる
    private var isSelectedMapButton = true
    @IBAction func MapButtonAction(_ sender: Any) {
//        let img: UIImage = isSelectedMapButton ? UIImage(named: "PositionDark")! : UIImage(named: "PositionThin")!
//        mapButton.setImage(img, for: .normal)
//        isSelectedMapButton.toggle()
        
        moveScrollView(at: 2)
        updateMenuButtonLayout(type: .map)
    }
    
    //ハート押したら濃くなる
    private var isSelectedFavoriteButton = true
    @IBAction func favoriteButtonAction(_ sender: Any) {
//        let img: UIImage = isSelectedFavoriteButton ? UIImage(named: "HeartDark")! : UIImage(named: "HeartThin")!
//        favoriteButton.setImage(img, for: .normal)
//        isSelectedFavoriteButton.toggle()
        
        moveScrollView(at: 1)
        updateMenuButtonLayout(type: .favorite)
        
    }
    //写真マーク押したら濃くなる
    private var isSelectedPhotoButton = true
    @IBAction func photoButtonAction(_ sender: Any) {
//        let img: UIImage = isSelectedPhotoButton ? UIImage(named: "PhotoDark")! : UIImage(named: "PhotoThin")!
//        photoImageButton.setImage(img, for: .normal)
//        isSelectedPhotoButton.toggle()
        moveScrollView(at: 0)
        updateMenuButtonLayout(type: .photo)
    }
    
    private func moveScrollView(at index: Int) {
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: true)
        collectionView.isPagingEnabled = true
    }
    
    enum MenuButtonType: Int {
        case favorite = 1
        case photo = 0
        case map = 2
        
        var active: UIImage {
            switch self {
            case .favorite:
                return Asset.Images.heartDark.image
            case .photo:
                return Asset.Images.photoDark.image
            case .map:
                return Asset.Images.positionDark.image
            }
        }
        
        var inActive: UIImage {
            switch self {
            case .favorite:
                return Asset.Images.heartThin.image
            case .photo:
                return Asset.Images.photoThin.image
            case .map:
                return Asset.Images.positionThin.image
            }
        }
    }
    
    private func updateMenuButtonLayout(type: MenuButtonType) {
        photoImageButton.setImage(MenuButtonType.photo.inActive, for: .normal)
        favoriteButton.setImage(MenuButtonType.favorite.inActive, for: .normal)
        mapButton.setImage(MenuButtonType.map.inActive, for: .normal)
        
        switch type {
        case .favorite:
            favoriteButton.setImage(type.active, for: .normal)
        case .photo:
            photoImageButton.setImage(type.active, for: .normal)
        case .map:
            mapButton.setImage(type.active, for: .normal)
        }
    }
    
    var postCount: Int?
    var posts = [Post]()
    
    func getUserPostData(){
        Firestore.firestore().collection("Posts").whereField("postUserUid", isEqualTo: user.uid).getDocuments(completion: {[weak self] (snapshot, error) in
            if let error = error {
                print("投稿データの取得に失敗しました。\(error)")
                return
            }
            
            self?.postCount = snapshot!.documents.count
            for document in snapshot!.documents {
                let post = Post(dic: document.data(), postId: document.documentID)
                if !post.deleted {
                    self?.posts.append(post)
                    self?.posts.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                }
            }
            
            self?.collectionView.reloadData()
        })

    }
    
    var likePostCount: Int?
    var likePosts = [Post]()
    
    func getUserFavoriteData(){
        
        Firestore.firestore().collection("Likes").whereField("uid", isEqualTo: Profile.shared.loginUser.uid).getDocuments(completion: { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }else {
                
                self?.likePostCount = snapshot!.documents.count
                for document in snapshot!.documents {
                    let likeData = LikeUsers(dic: document.data())
                    Firestore.firestore().collection("Posts").document(likeData.postId).getDocument { (postSnapshot, err) in
                        if let err = err {
                            print("投稿情報の取得に失敗しました。\(err)")
                            return
                        }
                        guard let dic = postSnapshot?.data() else { return }
                        let post = Post(dic: dic, postId: likeData.postId)
                        if !post.deleted {
                            self?.likePosts.append(post)
                            self?.likePosts.sort { (m1, m2) -> Bool in
                                let m1Date = m1.createdAt.dateValue()
                                let m2Date = m2.createdAt.dateValue()
                                return m1Date < m2Date
                            }
                        }
                    }
                }
                
                self?.collectionView.reloadData()
            }
        })
        
        
        Firestore.firestore().collectionGroup("likeUsers").whereField("uid", isEqualTo: user.uid).getDocuments(completion: {[weak self] (snapshot, error) in
            if let error = error {
                print("投稿データの取得に失敗しました。\(error)")
                return
            }
            
            self?.postCount = snapshot!.documents.count
            for document in snapshot!.documents {
                print("dic\(document.data())")
//                let post = Post(dic: document.data(), postId: document.documentID)
//                self?.posts.append(post)
//                self?.posts.sort { (m1, m2) -> Bool in
//                    let m1Date = m1.createdAt.dateValue()
//                    let m2Date = m2.createdAt.dateValue()
//                    return m1Date < m2Date
//                }
            }
            self?.collectionView.reloadData()
        })

    }
    

}

extension ProfileViewController: UICollectionViewDataSource {
    //この部分で３分割してる
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itsMe ? 3 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            // prof cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
            cell.user = user
            cell.configView()
            cell.posts = posts
            cell.postCount = posts.count
            cell.pictureTapDelegate = self
            return cell
        }else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
            cell.user = user
            cell.configView()
            cell.posts = likePosts
            cell.postCount = likePosts.count
            cell.pictureTapDelegate = self
            return cell
        }else if indexPath.row == 2 {
            // map cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapViewCollectionViewCell", for: indexPath) as! MapViewCollectionViewCell
            cell.delegate = self
            cell.getUserPostData()
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected", indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.visibleCells.first,
           let index = collectionView.indexPath(for: cell),
           let menu = MenuButtonType(rawValue: index.row) {
            print("scroll", menu)
            updateMenuButtonLayout(type: menu)
        }
    }
}

extension ProfileViewController: pinTapDelegate {
    func pinTap(postId: String) {
        Firestore.firestore().collection("Posts").document(postId).getDocument {[weak self] (snapshot, err) in
            if let err = err {
                print("投稿情報の取得に失敗しました。\(err)")
                return
            }
            guard let dic = snapshot?.data() else { return }
            let post = Post(dic: dic, postId: postId)
            
            Goto.ChatRoomView(view: self!, image: URL(string: post.rawImageUrl)!, post: post)
            
        }
    }
}

extension ProfileViewController: PictureTapDelegate {
    func picutureTap(post: Post) {
        if let imageUrl = URL(string: post.rawImageUrl) {
            Goto.ChatRoomView(view: self, image: imageUrl, post: post)
        }
    }
    
    
}

//class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    
//    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var backImageView: UIImageView!
//    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var optionButton: UIButton!
//
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    let displayDebugging = true
//    private var isInitialMoveToMap: Bool = true
//
//    var ar = ARViewController()
//
//    var userAnnotation: MKPointAnnotation?
//    var locationEstimateAnnotation: MKPointAnnotation?
//
//    var updateUserLocationTimer: Timer?
//    var updateInfoLabelTimer: Timer?
//
//    var centerMapOnUserLocation: Bool = true
//    var routes: [MKRoute]?
//
//    let db = Firestore.firestore()
//
//    let storage = FirebaseStorage.Storage.storage()
//
//    var loginUser: User!
////    var user: User!
//
//    var user: User!
//
//    let accessory = Accessory()
//
//    // image
//    private var imagePicker = UIImagePickerController()
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        configView()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
//    }
//
//    func configView(){
//
//        getUserPostData()
//
//        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
//
//        loginUser = Profile.shared.loginUser
//
//
//        imagePicker.allowsEditing = true
//        imagePicker.modalPresentationStyle = .fullScreen
//
//        imagePicker.delegate = self
//
//        backImageView.isUserInteractionEnabled = true
//        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
//
//        //MARK: - FireStorage
//        //        let uid = loginUser.uid
//        //        switch Profile.shared.updateProfileImage() {
//        //        case .success(let image):
//        //            profileImageView.setImage(image: image, name: uid)
//        //        case .failure(_):
//        //            break
//        //        }
//
//        if let url = URL(string: user.profileImage){
//            profileImageView.af.setImage(withURL: url)
//        }
////        profileImageView.loadImageAsynchronously(url: URL(string: user.profileImage))
//
////        if user.email != Profile.shared.loginUser.email{
////            changeProfileImageButton.isHidden = true
////            followAndMessageButtonStackView.isHidden = false
////            followButton.layer.cornerRadius = 10
////            messageButton.layer.cornerRadius = 10
////
////        }
//
//        userNameLabel.text = user.userName
//
//        optionButton.imageView?.contentMode = .scaleAspectFill
//        optionButton.contentHorizontalAlignment = .fill
//        optionButton.contentVerticalAlignment = .fill
//
//
//    }
//
//    //MARK: ユーザーが投稿したのを全て取得
//    func getUserPostData(){
//        print("よばれた uid:\(user.uid)")
//        Firestore.firestore().collection("Posts").whereField("postUserUid", isEqualTo: user.uid).getDocuments(completion: {[weak self] (snapshot, error) in
//            if let error = error {
//                print("投稿データの取得に失敗しました。\(error)")
//                return
//            }
//
//            for document in snapshot!.documents {
//                let post = Post(dic: document.data(), postId: document.documentID)
//                let pin = MKPointAnnotation()
//                pin.subtitle = post.postId
//                pin.accessibilityValue = post.postId
//                pin.coordinate = CLLocationCoordinate2DMake(post.latitude, post.longitude)
//                self?.mapView.addAnnotation(pin)
//
//            }
//        })
//    }
//
//
//
//    //User Location
//    let locationManager:CLLocationManager = CLLocationManager()
//
//    var userLocation = MKUserLocation()
//
//    override func viewWillAppear(_ animated: Bool) {
//        mapView.delegate = self
//
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = kCLHeadingFilterNone
//        locationManager.startUpdatingLocation()
//        locationManager.delegate = self
//
//        //        loginUser = Profile.shared.loginUser
//
//        mapView.showsUserLocation = true
//
//        updateUserLocation()
//
//        userNameLabel.text = user.userName
//        userIdLabel.text = user.email
//
//        moveTo(center: mapView.userLocation.coordinate, animated: true)
//        // ローカルファイルからユーザーアイコンを取得・表示する
////        downloadProfileImage()
//
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
//    }
//
//    private func moveTo(
//        center location: CLLocationCoordinate2D,
//        animated: Bool,
//        span: CLLocationDegrees = 0.01) {
//            mapView.centerCoordinate = location
//            mapView.region = .init(center: location, span: .init(latitudeDelta: span, longitudeDelta: span))
//        }
//
//    //MARK: 前の画面に戻る
//    @objc func backView(_ sender: Any){
//        print("push back image")
//        self.navigationController?.popViewController(animated: true)
//    }
//
//
//    //MARK: - ハンバーガーボタン
//
//    @IBAction func pushOptionButton(_ sender: Any) {
//
//        if user.email == Profile.shared.loginUser.email {
//            // styleをActionSheetに設定
//            let alertSheet = UIAlertController(title: LocalizeKey.accountSetting.localizedString(), message: "", preferredStyle: UIAlertController.Style.actionSheet)
//
//            let action1 = UIAlertAction(title: LocalizeKey.changeYourProfile.localizedString(), style: UIAlertAction.Style.default, handler: {[weak self]
//                (action: UIAlertAction!) -> Void in
//                self?.pushChangeProfile()
//
//            })
//
//            let action2 = UIAlertAction(title: LocalizeKey.signOut.localizedString(), style: UIAlertAction.Style.destructive, handler: {[weak self]
//                (action: UIAlertAction!) -> Void in
//                self?.pushSignOut()
//            })
//            let action3 = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: UIAlertAction.Style.cancel, handler: {
//                (action: UIAlertAction!) in
//            })
//
//            // アクションを追加.
//            alertSheet.addAction(action1)
//            alertSheet.addAction(action2)
//            alertSheet.addAction(action3)
//
//            self.present(alertSheet, animated: true, completion: nil)
//        } else {
//            // styleをActionSheetに設定
//            let alertSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
//
//            let userMute = UIAlertAction(title: LocalizeKey.mute.localizedString(), style: UIAlertAction.Style.destructive, handler: {
//                (action: UIAlertAction!)  in
//            })
//
//            let userBlock = UIAlertAction(title: LocalizeKey.block.localizedString(), style: UIAlertAction.Style.destructive, handler: {
//                (action: UIAlertAction!)  in
//            })
//
//            let userReport = UIAlertAction(title: LocalizeKey.report.localizedString(), style: UIAlertAction.Style.destructive, handler: {
//                (action: UIAlertAction!)  in
//            })
//
//            let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: UIAlertAction.Style.cancel, handler: {
//                (action: UIAlertAction!) in
//            })
//
//            // アクションを追加.
//            alertSheet.addAction(userMute)
//            alertSheet.addAction(userBlock)
//            alertSheet.addAction(userReport)
//            alertSheet.addAction(cancel)
//
//            self.present(alertSheet, animated: true, completion: nil)
//        }
//
//
//    }
//
//    var delegate : SignOutProtocol?
//
//    func pushSignOut(){
//        do {
//            try Auth.auth().signOut()
//            Profile.shared.isLogin = false
//            delegate?.signOut(check: true)
//            self.dismiss(animated: true, completion: nil)
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//    }
//
//    func pushChangeProfile(){
//        Goto.ChangeProfile(view: self, user: loginUser)
//    }
//
//    //MARK: ハンバーガーボタン -
//
//
//    @objc func updateUserLocation() {
//        guard let currentLocation = ar.sceneLocationView.sceneLocationManager.currentLocation else {
//            return
//        }
//
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {
//                return
//            }
//
//            if self.userAnnotation == nil {
//                self.userAnnotation = MKPointAnnotation()
//                self.mapView.addAnnotation(self.userAnnotation!)
//            }
//
//            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
//                self.userAnnotation?.coordinate = currentLocation.coordinate
//            }, completion: nil)
//
//            if self.centerMapOnUserLocation {
//                UIView.animate(withDuration: 0.45,
//                               delay: 0,
//                               options: .allowUserInteraction,
//                               animations: {
//                    self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
//                }, completion: { _ in
//                    self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
//                })
//            }
//
//            if self.displayDebugging {
//                if self.locationEstimateAnnotation != nil {
//                    self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
//                    self.locationEstimateAnnotation = nil
//                }
//            }
//        }
//    }
//
//    private func MAPLoad(){
//
//    }
//
//
//    @IBAction func pushChangeImage(_ sender: Any) {
//
//        if #available(iOS 14.0, *) {
//            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
//                switch status {
//                case .authorized:
//                    print("許可ずみ")
//                    break
//                case .limited:
//                    print("制限あり")
//                    break
//                case .denied:
//                    print("拒否ずみ")
//                    break
//                default:
//                    break
//                }
//            }
//        }else  {
//            if PHPhotoLibrary.authorizationStatus() != .authorized {
//                PHPhotoLibrary.requestAuthorization { status in
//                    if status == .authorized {
//                        print("許可ずみ")
//                    } else if status == .denied {
//                        print("拒否ずみ")
//                    }
//                }
//            } else {
//
//            }
//        }
//
//
//        // 権限
//        let authPhotoLibraryStatus = PHPhotoLibrary.authorizationStatus()
//        // authPhotoLibraryStatus = .authorized : 許可
//        //                        = .limited    : 選択した画像のみ
//        //                        = .denied     : 拒否
//
//        if authPhotoLibraryStatus == .limited {
//
//            //アラートの設定
//            let alert = UIAlertController(title: "Failed to save image", message: "Allow this app to access Photos.", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "Enable photos access", style: .default) { (action) in
//                //設定を開く
//                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.canOpenURL(settingURL)
//                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
//                }
//            }
//            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (acrion) in
//                self.dismiss(animated: true, completion: nil)
//            }
//
//            //アラートの下にあるボタンを追加
//            alert.addAction(cancel)
//            alert.addAction(ok)
//            //アラートの表示
//            present(alert, animated: true, completion: nil)
//
//
//        }
//        if authPhotoLibraryStatus == .denied {
//
//            //アラートの設定
//            let alert = UIAlertController(title: "Failed to save image", message: "Allow this app to access Photos.", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "Enable photos access", style: .default) { (action) in
//                //設定を開く
//                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.canOpenURL(settingURL)
//                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
//                }
//            }
//            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (acrion) in
//                self.dismiss(animated: true, completion: nil)
//            }
//
//            //アラートの下にあるボタンを追加
//            alert.addAction(cancel)
//            alert.addAction(ok)
//            //アラートの表示
//            present(alert, animated: true, completion: nil)
//        }
//        // fix/update_prof_image_#33 >>>
//        if authPhotoLibraryStatus == .authorized {
//            // <<<
//            present(imagePicker, animated: true)    // カメラロール起動
//        }
//        print("change image")
//    }
//
//    private func changeProfileImage(){
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.allowsEditing = true
//
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    // ローカルファイルのURL取得
//    func getFileURL(fileName: String) -> URL {
//        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        return docDir.appendingPathComponent(fileName)
//    }
//
//    // ローカルファイルから画像取得して表示する
//    func downloadProfileImage(){
//        let path = getFileURL(fileName: loginUser.uid+".jpeg").path
//
//        if FileManager.default.fileExists(atPath: path) {
//            if let imageData = UIImage(contentsOfFile: path) {
//                profileImageView.image = imageData
//            }else {
//                print("Failed to load the image.")
//            }
//        }else {
//            print("Image file not found.")
//        }
//    }
//
//    public func saveImageFile(url: URL, fileName: String) {
//        print("Download Started")
//        getData(from: url) { data, response, error in
//            if let error = error {
//                print(error)
//                return
//            }
//            DispatchQueue.main.async() { [weak self] in
//                do {
//                    //URLをデータに変換
//                    let imageData = try Data(contentsOf: url)
//                    //データをUIImage(jpg)に変換
//                    if let jpegImageData = UIImage(data: imageData)?.jpegData(compressionQuality: 1.0),
//                       let saveDocumentPath = self?.getFileURL(fileName: fileName) {
//                        do {
//                            //端末に保存
//                            try jpegImageData.write(to: saveDocumentPath)
//                            print("Image saved.")
//                        } catch {
//                            print("Failed to save the image:", error)
//                        }
//                    }
//                } catch {
//                    print("変換失敗")
//                }
//            }
//        }
//    }
//
//    //画像保存
//    // DocumentディレクトリのfileURLを取得
//    func getDocumentsURL() -> NSURL {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
//        return documentsURL
//    }
//    // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
//    func fileInDocumentsDirectory(filename: String) -> String {
//        let fileURL = getDocumentsURL().appendingPathComponent(filename)
//        return fileURL?.path ?? ""
//    }
//    //画像を保存するメソッド
//    func saveImage (image: UIImage, path: String ) -> Bool {
//        let jpgImageData = image.jpegData(compressionQuality:0.5)
//        do {
//            try jpgImageData!.write(to: URL(fileURLWithPath: path), options: .atomic)
//        } catch {
//            print(error)
//            return false
//        }
//        return true
//    }
//
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
//
////    func saveToFireStorege(selectedImage: UIImage){
////        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
////
////        let fileName = loginUser.uid+".jpeg"
////        let storageRef = Storage.storage().reference().child("profile").child(fileName)
////
////        let metaData = FirebaseStorage.StorageMetadata()
////        metaData.contentType = "image/jpeg"
////
////        storageRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
////            if let err = err{
////                print("firestorageへの情報の保存に失敗\(err)")
////                return
////            }
////
////            print("保存に成功")
////
////            storageRef.downloadURL { [weak self] (url, err) in
////                if let err = err {
////                    print("error\(err)")
////                    return
////                }
////                guard let urlString = url?.absoluteString else { return }
////                self?.updateProfileImageToFirestore(profileImageUrl: urlString, image: selectedImage)
////            }
////        }
////    }
//
//    func saveFirebaseStorage(image: UIImage){
//        accessory.saveToFireStorege(selectedImage: image, fileName: loginUser.uid+".jpeg", folderName: "profile") { [weak self] result in
//            switch result {
//            case .success((let urlString, let returnImage)):
//                self?.updateProfileImageToFirestore(profileImageUrl: urlString, image: returnImage)
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
//    }
//
//    func updateProfileImageToFirestore(profileImageUrl: String, image: UIImage){
//        //        Firestore.firestore().document("users").collection(Profile.shared.userId).value(forKey: "")
//        let doc = Firestore.firestore().collection("Users").document(loginUser.uid)
//        doc.updateData([
//            "profileImage" : profileImageUrl]
//        ) { [weak self] err in
//            if let err = err {
//                print("firestoreの更新に失敗\(err)")
//                return
//            }
//            print("更新成功")
//            self?.saveImageToDevice(image: image, fileName: Profile.shared.loginUser.uid+".jpeg")
//
//        }
//
//    }
//
//    func saveImageToDevice(image: UIImage, fileName: String) {
//        print("Download Started")
//        DispatchQueue.main.async() { [weak self] in
//            //データをUIImage(jpg)に変換
//            if let jpegImageData = image.jpegData(compressionQuality: 1.0),
//               let saveDocumentPath = self?.getFileURL(fileName: fileName) {
//                do {
//                    //端末に保存
//                    try jpegImageData.write(to: saveDocumentPath)
//                    self?.dismiss(animated: true)
//                    self?.profileImageView.image = image
//                    print("Image saved.")
//                } catch {
//                    print("Failed to save the image:", error)
//                }
//            }
//        }
//    }
//
//    func saveFirebase(selectedImage: UIImage){
//        // 画像表示
//        profileImageView.image = selectedImage
//        // 格納先 reference
//        let path = FirebaseStorage.Storage.storage().reference(forURL: "gs://metamera-e2b4b.appspot.com")
//        let localImageRef = path.child("profile").child(loginUser.uid+".jpeg")
//
//        // メタデータ
//        let metaData = FirebaseStorage.StorageMetadata()
//        metaData.contentType = "image/jpeg"
//
//        // UIImageをdata型に変換
//        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
//            return
//        }
//        dismiss(animated: true) {
//            // データをアップロード
//            localImageRef.putData(imageData, metadata: metaData) { metaData, error in
//                if let error = error {
//                    fatalError(error.localizedDescription)
//                    print("error",error)
//                }
//                // completion
//                // ダウンロードURLの取得
//                localImageRef.downloadURL { [weak self] url, error in
//                    if let error = error {
//                        fatalError(error.localizedDescription)
//                    }
//                    guard let downloadURL = url else {
//                        // ダウンロードURL取得失敗
//                        return
//                    }
//                    // 画像ファイルを保存する
//                    self?.saveImageFile(url: downloadURL, fileName: Profile.shared.loginUser.uid+".jpeg")
//                    self?.updateProfileImageToFirestore(profileImageUrl: downloadURL.absoluteString, image: selectedImage)
//
//                }
//            }
//        }
//    }
    
//}

//extension ProfileViewController: MKMapViewDelegate{
//    //MARK: ピンをタップしたときのイベント
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let annotations = view.annotation{
//
//            guard let subtitle = annotations.subtitle! else {
//                print("nil")
//                return
//            }
//
//            Firestore.firestore().collection("Posts").document(subtitle).getDocument {[weak self] (snapshot, err) in
//                if let err = err {
//                    print("投稿情報の取得に失敗しました。\(err)")
//                    return
//                }
//                guard let dic = snapshot?.data() else { return }
//                let post = Post(dic: dic, postId: subtitle)
//
//                Goto.ChatRoomView(view: self!, image: URL(string: post.rawImageUrl)!, post: post)
//
//            }
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
//
//        if annotation is MKUserLocation {
//            return nil
//        }
//        return annotationView
//    }
//
//
//}
//
//
//extension ProfileViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        // 位置情報
//        guard let location = manager.location?.coordinate else {
//            return
//        }
//
//        if isInitialMoveToMap {
//            // map表示 現在地に移動
//            moveTo(
//                center: .init(
//                    latitude: location.latitude,
//                    longitude: location.longitude
//                ),
//                animated: true
//            )
//            isInitialMoveToMap.toggle()
//        }
//    }
//
//}
//
//extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let editImage = info[.editedImage] as? UIImage {
//            //            self.saveFirebase(selectedImage: editImage)
////            self.saveToFireStorege(selectedImage: editImage)
//            self.saveFirebaseStorage(image: editImage)
//        }else if let originalImage = info[.originalImage] as? UIImage {
//            //            self.saveFirebase(selectedImage: originalImage)
//            self.saveFirebaseStorage(image: originalImage)
//        }
//    }
//
//}

protocol SignOutProtocol:AnyObject {
    
    //    func catchData(count: Int)
    func signOut(check: Bool)
    
}

