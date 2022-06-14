//
//  ProfileViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/06/05.
//

import ARCL
import UIKit
import MapKit
import Photos
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    
    let displayDebugging = true
    
    var ar = ARViewController()
    
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?
    
    var centerMapOnUserLocation: Bool = true
    var routes: [MKRoute]?
    
    let db = Firestore.firestore()
    
    let storage = FirebaseStorage.Storage.storage()
    
    
    
    
    
    // image
    private var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImage.layer.cornerRadius = 25
        changeProfileImageButton.layer.cornerRadius = 13
        
        MapView.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        
        //MARK: - FireStorage
        FirebaseApp.configure()
        
        
    }
    
    //User Location
    let locationManager:CLLocationManager = CLLocationManager()
    
    var userLocation = MKUserLocation()
    
    override func viewWillAppear(_ animated: Bool) {
        //MapView.delegate = self
        //MapView.isZoomEnabled = true
        //MapView.isScrollEnabled = true
        //MapView.isRotateEnabled = true
        MapView.mapType = .standard
        //MapView.showsCompass = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone
        locationManager.startUpdatingLocation()
        
        MapView.showsUserLocation = true
        //MapView.isPitchEnabled = true
        
        // 縮尺を設定
        //        var region:MKCoordinateRegion = MapView.region
        //        region.center = CLLocationCoordinate2DMake(userLocation)
        //        region.span.latitudeDelta = 0.02
        //        region.span.longitudeDelta = 0.02
        //
        //        MapView.setRegion(region,animated:true)
        
        moveTo(center: CLLocationCoordinate2DMake(35.624929, 139.341696), animated: true)
        
    }
    
    private func moveTo(
        center location: CLLocationCoordinate2D,
        animated: Bool,
        span: CLLocationDegrees = 0.01) {
            
            let coordinateSpan = MKCoordinateSpan(
                latitudeDelta: span,
                longitudeDelta: span
            )
            let coordinateRegion = MKCoordinateRegion(
                center: location,
                span: coordinateSpan
            )
            MapView.setRegion(
                coordinateRegion,
                animated: animated
            )
        }
    
    
    @objc func updateUserLocation() {
        guard let currentLocation = ar.sceneLocationView.sceneLocationManager.currentLocation else {
            return
        }
        
        DispatchQueue.main.async { [weak self ] in
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
        // カメラロール呼び出し
        //let picker = UIImagePickerController()
        //present(picker, animated: true)
        //picker.delegate = self
        // 写真選択
        // 画像をデータに変換
        // firestorageにアップロード
        
        // 顕現
        let authPhotoLibraryStatus = PHPhotoLibrary.authorizationStatus()
        // 許可されてる場合のみ
        if authPhotoLibraryStatus == .authorized {
            
            
            present(imagePicker, animated: true)
            
            
            
        }
        
        //        guard let imageData = image.jpegData(compressionQuality: 0.3)
        //                let imageRef = Storage.storage().reference().child("")
        print("change image")
    }
    
}

extension ProfileViewController: MKMapViewDelegate{
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("map 起動")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("map 起動完了")
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // 格納先 reference
//            let imageRef = FirebaseStorage.Storage.storage().reference().child("test/test.jpg")
            let path = FirebaseStorage.Storage.storage().reference(forURL: "gs://metamera-e2b4b.appspot.com")
            let imageRef = path.child("test").child("test.jpeg")
            //            let userRef = db.collection("").document()
            // メタデータ
            let metaData = FirebaseStorage.StorageMetadata()
            metaData.contentType = "image/jpeg"
                        
            // UIImageをdata型に変換
            guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
                return
            }
            // データをアップロード
            imageRef.putData(imageData, metadata: metaData) { metaData, error in
                if let error = error {
                    fatalError(error.localizedDescription)
                    return
                }
                // completion
                // ダウンロードURLの取得
                imageRef.downloadURL { url, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                        return
                    }
                    guard let downloadURL = url else {
                        // ダウンロードURL取得失敗
                        return
                    }
                    // success
                    
                }
            }
            
            
            
            
//            let uploadFile = imageRef.putFile(from: selectedImage, metadata: metaData) { metadata, error in
//                guard let metadata = metadata else {
//                    return
//                }
//            }
//            //            imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
//            //                if let error = error {
//            //                    self.handleError(error: error, msg: "Unable to upload image.")
//            //                return
//            //               }
//
//            // 5：画像がアップロードされたら、ダウンロードURLを取得
//            imageRef.downloadURL { (url, error) in
//                if let error = error {
//                    fatalError(error.localizedDescription)
////                    self.handleError(error: error, msg: "Unable to download URL.")
//                    return
//                }
//                guard let url = url else { return }
//
//                // 6：新しいドキュメントをFirestoreコレクションにアップロード
//                // uploadDocumentは関数を用意してあげる
//                // Firebaseへの登録時の構造体を初期化して、setDataメソッドでデータをセットしてあげる
//                self.uploadDocument(url: url.absoluteString)
//            }
        }
    }
}


