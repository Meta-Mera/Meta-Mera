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
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import Nuke

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var MapView: MKMapView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    let displayDebugging = true
    private var isInitialMoveToMap: Bool = true
    
    var ar = ARViewController()
    
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?
    
    var centerMapOnUserLocation: Bool = true
    var routes: [MKRoute]?
    
    let db = Firestore.firestore()
    
    let storage = FirebaseStorage.Storage.storage()
    
    private var user:User?{
        didSet{
            userNameLabel.text = user?.userName
        }
    }
    
    
    // image
    private var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        changeProfileImageButton.layer.cornerRadius = 13
        
        
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        
        MapView.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
        
        //MARK: - FireStorage
        let uid = Profile.shared.userId
        switch Profile.shared.updateProfileImage() {
        case .success(let image):
            profileImageView.setImage(image: image, name: uid)
        case .failure(_):
            break
        }
        
//        userNameLabel.text = Profile.shared.userName
//        userIdLabel.text = Profile.shared.userEmail
        
        
    }
    
    
    
    //User Location
    let locationManager:CLLocationManager = CLLocationManager()
    
    var userLocation = MKUserLocation()
    
    override func viewWillAppear(_ animated: Bool) {
        MapView.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        MapView.showsUserLocation = true
        
        updateUserLocation()
        
        userNameLabel.text = Profile.shared.userName
        userIdLabel.text = Profile.shared.userEmail
        
        
//        var test = Profile.shared.getUser(userId: "")
    
        
        
        moveTo(center: MapView.userLocation.coordinate, animated: true)
        // ローカルファイルからユーザーアイコンを取得・表示する
        downloadProfileImage()
    }
    
    private func moveTo(
        center location: CLLocationCoordinate2D,
        animated: Bool,
        span: CLLocationDegrees = 0.01) {
            MapView.centerCoordinate = location
            MapView.region = .init(center: location, span: .init(latitudeDelta: span, longitudeDelta: span))
    }
    
    //MARK: 前の画面に戻る
    @objc func backView(_ sender: Any){
        print("push back image")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func updateUserLocation() {
        guard let currentLocation = ar.sceneLocationView.sceneLocationManager.currentLocation else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.userAnnotation == nil {
                self.userAnnotation = MKPointAnnotation()
                self.MapView.addAnnotation(self.userAnnotation!)
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.userAnnotation?.coordinate = currentLocation.coordinate
            }, completion: nil)
            
            if self.centerMapOnUserLocation {
                UIView.animate(withDuration: 0.45,
                               delay: 0,
                               options: .allowUserInteraction,
                               animations: {
                    self.MapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                }, completion: { _ in
                    self.MapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                })
            }
            
            if self.displayDebugging {
                if self.locationEstimateAnnotation != nil {
                    self.MapView.removeAnnotation(self.locationEstimateAnnotation!)
                    self.locationEstimateAnnotation = nil
                }
            }
        }
    }
    
    private func MAPLoad(){
        
    }
    
    
    @IBAction func pushChangeImage(_ sender: Any) {
        //iOS14に対応
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
        print("change image")
    }
    
    private func changeProfileImage(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // ローカルファイルのURL取得
    func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    // ローカルファイルから画像取得して表示する
    func downloadProfileImage(){
        let path = getFileURL(fileName: Profile.shared.userId+".jpeg").path
        
        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
                profileImageView.image = imageData
            }else {
                print("Failed to load the image.")
            }
        }else {
            print("Image file not found.")
        }
    }
    
    func saveImageFile(url: URL, fileName: String) {
        print("Download Started")
        getData(from: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async() { [weak self] in
                do {
                    //URLをデータに変換
                    let imageData = try Data(contentsOf: url)
                    //データをUIImage(jpg)に変換
                    if let jpegImageData = UIImage(data: imageData)?.jpegData(compressionQuality: 1.0),
                       let saveDocumentPath = self?.getFileURL(fileName: fileName) {
                        do {
                            //端末に保存
                            try jpegImageData.write(to: saveDocumentPath)
                            print("Image saved.")
                        } catch {
                            print("Failed to save the image:", error)
                        }
                    }
                } catch {
                    print("変換失敗")
                }
            }
        }
    }
    
    //画像保存
    // DocumentディレクトリのfileURLを取得
    func getDocumentsURL() -> NSURL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        return documentsURL
    }
    // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL?.path ?? ""
    }
    //画像を保存するメソッド
    func saveImage (image: UIImage, path: String ) -> Bool {
        let jpgImageData = image.jpegData(compressionQuality:0.5)
        do {
            try jpgImageData!.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func saveToFireStorege(selectedImage: UIImage){
        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        let fileName = Profile.shared.userId+".jpeg"
        let storageRef = Storage.storage().reference().child("profile").child(fileName)
        
        let metaData = FirebaseStorage.StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(uploadImage, metadata: metaData) { (metadata, err) in
            if let err = err{
                print("firestorageへの情報の保存に失敗\(err)")
                return
            }
            
            print("保存に成功")
            
            storageRef.downloadURL { [weak self] (url, err) in
                if let err = err {
                    print("error\(err)")
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                self?.updateProfileImageToFirestore(profileImageUrl: urlString, image: selectedImage)
            }
        }
    }
    
    func updateProfileImageToFirestore(profileImageUrl: String, image: UIImage){
//        Firestore.firestore().document("users").collection(Profile.shared.userId).value(forKey: "")
        let doc = Firestore.firestore().collection("users").document(Profile.shared.userId)
        doc.updateData([
            "profileImage" : profileImageUrl]
        ) { [weak self] err in
            if let err = err {
                print("firestoreの更新に失敗\(err)")
                return
            }
            print("更新成功")
            self?.saveImageToDevice(image: image, fileName: Profile.shared.userId+".jpeg")
            
        }
        
    }
    
    func saveImageToDevice(image: UIImage, fileName: String) {
        print("Download Started")
        DispatchQueue.main.async() { [weak self] in
            //データをUIImage(jpg)に変換
            if let jpegImageData = image.jpegData(compressionQuality: 1.0),
               let saveDocumentPath = self?.getFileURL(fileName: fileName) {
                do {
                    //端末に保存
                    try jpegImageData.write(to: saveDocumentPath)
                    self?.dismiss(animated: true)
                    self?.profileImageView.image = image
                    print("Image saved.")
                } catch {
                    print("Failed to save the image:", error)
                }
            }
        }
    }
    
    func saveFirebase(selectedImage: UIImage){
        // 画像表示
        profileImageView.image = selectedImage
        // 格納先 reference
        let path = FirebaseStorage.Storage.storage().reference(forURL: "gs://metamera-e2b4b.appspot.com")
        let localImageRef = path.child("profile").child(Profile.shared.userId+".jpeg")
        
        // メタデータ
        let metaData = FirebaseStorage.StorageMetadata()
        metaData.contentType = "image/jpeg"
                    
        // UIImageをdata型に変換
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            return
        }
        dismiss(animated: true) {
            // データをアップロード
            localImageRef.putData(imageData, metadata: metaData) { metaData, error in
                if let error = error {
                    fatalError(error.localizedDescription)
                    print("error",error)
                }
                // completion
                // ダウンロードURLの取得
                localImageRef.downloadURL { [weak self] url, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    guard let downloadURL = url else {
                        // ダウンロードURL取得失敗
                        return
                    }
                    // 画像ファイルを保存する
                    self?.saveImageFile(url: downloadURL, fileName: Profile.shared.userId+".jpeg")
                    self?.updateProfileImageToFirestore(profileImageUrl: downloadURL.absoluteString, image: selectedImage)
                    
                }
            }
        }
    }
    
}

extension ProfileViewController: MKMapViewDelegate{
    
}


extension ProfileViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 位置情報
        guard let location = manager.location?.coordinate else {
            return
        }
        
        if isInitialMoveToMap {
            // map表示 現在地に移動
            moveTo(
                center: .init(
                    latitude: location.latitude,
                    longitude: location.longitude
                ),
                animated: true
            )
            isInitialMoveToMap.toggle()
        }
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
//            self.saveFirebase(selectedImage: editImage)
            self.saveToFireStorege(selectedImage: editImage)
        }else if let originalImage = info[.originalImage] as? UIImage {
//            self.saveFirebase(selectedImage: originalImage)
            self.saveToFireStorege(selectedImage: originalImage)
        }
    }
    
}
