//
//  ProfileViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/06/05.
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

// TODO: changeProfile
// TODO: ChatRoom


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoImageButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    var loginUser: User!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        setupProfileData()
    }
    
    /// 画面レイアウト
    private func configView() {
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        
        // collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "ProfileCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: collectionView.bounds.width, height: collectionView.bounds.height)
        collectionView.collectionViewLayout = layout
    }
    
    /// ユーザープロフィールデータを表示
    private func setupProfileData() {
        guard let profileData = Profile.shared.loginUser else {
            fatalError("not found user data")
            return
        }
        userNameLabel.text = profileData.userName
        if let userIconImageURL = URL(string: profileData.profileImage) {
            userIconImageView.af.setImage(withURL: userIconImageURL)
        }
        // 自己紹介文 DB ないんだが... to ジム
//        discriptionLabel.text = profileData.
    }
    
    // MARK: Action Buttons
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        
    }
    //マップボタン押したら濃くなる
    private var isSelectedMapButton = true
    @IBAction func MapButtonAction(_ sender: Any) {
        let img: UIImage = isSelectedMapButton ? UIImage(named: "PositionDark")! : UIImage(named: "PositionThin")!
        mapButton.setImage(img, for: .normal)
        isSelectedMapButton.toggle()
        
        moveScrollView(at: 2)
    }
    
    //ハート押したら濃くなる
    private var isSelectedFavoriteButton = true
    @IBAction func favoriteButtonAction(_ sender: Any) {
        let img: UIImage = isSelectedFavoriteButton ? UIImage(named: "HeartDark")! : UIImage(named: "HeartThin")!
        favoriteButton.setImage(img, for: .normal)
        isSelectedFavoriteButton.toggle()
        moveScrollView(at: 1)
        
    }
    //写真マーク押したら濃くなる
    private var isSelectedPhotoButton = true
    @IBAction func photoButtonAction(_ sender: Any) {
        let img: UIImage = isSelectedPhotoButton ? UIImage(named: "PhotoDark")! : UIImage(named: "PhotoThin")!
        photoImageButton.setImage(img, for: .normal)
        isSelectedPhotoButton.toggle()
        moveScrollView(at: 0)
    }
    
    private func moveScrollView(at index: Int) {
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: true)
        collectionView.isPagingEnabled = true
    }
        
}

extension ProfileViewController: UICollectionViewDataSource {
    //この部分で３分割してる
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
        cell.bind(indexPath.row)
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected", indexPath.row)
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
