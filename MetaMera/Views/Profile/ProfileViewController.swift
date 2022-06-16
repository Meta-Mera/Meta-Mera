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
        
        
        moveTo(center: MapView.userLocation.coordinate, animated: true)
        
        
    }
    
    private func moveTo(
        center location: CLLocationCoordinate2D,
        animated: Bool,
        span: CLLocationDegrees = 0.01) {
        
//        let coordinateSpan = MKCoordinateSpan(
//            latitudeDelta: span,
//            longitudeDelta: span
//        )
//        let coordinateRegion = MKCoordinateRegion(
//            center: location,
//            span: coordinateSpan
//        )
            MapView.centerCoordinate = location
            MapView.region = .init(center: location, span: .init(latitudeDelta: span, longitudeDelta: span))
//        MapView.setRegion(
//            coordinateRegion,
//            animated: animated
//        )
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        //iOS14に対応
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .limited:
                    print("制限あり")
                    break
                case .authorized:
                    print("許可ずみ")
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
        // 許可されてる場合のみ
        if authPhotoLibraryStatus == .authorized {
            
            
            present(imagePicker, animated: true)
            
            
            
        }
        print("change image")
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
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // 格納先 reference
            let path = FirebaseStorage.Storage.storage().reference(forURL: "gs://metamera-e2b4b.appspot.com")
            let imageRef = path.child("profile").child("test.jpeg")
            
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


