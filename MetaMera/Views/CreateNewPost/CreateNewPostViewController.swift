//
//  CreateNewPostViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/07/15.
//

import Foundation
import UIKit
import Photos
import MapKit
import PKHUD
import Firebase

class CreateNewPostViewController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var commentTextView: PlaceTextView!
    @IBOutlet weak var imageSelectButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stepper: UIStepper!
    
    
    let postUploadModel = PostUploadModel()
    let accessory = Accessory()
    
    // image
    private var imagePicker = UIImagePickerController()
    private var selectedImage = UIImage()
    private var imageIsSelected = false
    
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    //User Location
    let locationManager:CLLocationManager = CLLocationManager()
    
    var userLocation = MKUserLocation()
    var altitude : Double = 0
    
    var pointAno: MKPointAnnotation = MKPointAnnotation()
    
    private var isInitialMoveToMap: Bool = true
    private var isAnnotation: Bool = false
    
    private lazy var mapViewLongTapGuester: UILongPressGestureRecognizer = {
        let guester = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongTapped(_:)))
        return guester
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        changeProfileImage()
        isAnnotation = false
        debugButton.isEnabled = false
    }
    
    func configView(){
        
        mapView.delegate = self
        mapView.addGestureRecognizer(mapViewLongTapGuester)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        mapView.showsUserLocation = true
        
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
        
        moveTo(center: mapView.userLocation.coordinate, animated: true)
        
        // 円を描画する(半径500m).
        let myCircle: MKCircle = MKCircle(center: CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude,longitude: mapView.userLocation.coordinate.longitude), radius: CLLocationDistance(500))
        
        center = CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude,longitude: mapView.userLocation.coordinate.longitude)
        
        // mapViewにcircleを追加.
        mapView.addOverlay(myCircle)
        
        altitudeTextField.isUserInteractionEnabled = false
        
        altitude = floor(mapView.userLocation.location!.altitude) + 20
        editAltitude = altitude
        altitudeTextField.text = "\(altitude)"
        
        commentTextView.placeHolder = "コメントを入力してください。"
        
        
    }
    
    private func moveTo(
        center location: CLLocationCoordinate2D,
        animated: Bool,
        span: CLLocationDegrees = 0.01) {
            mapView.centerCoordinate = location
            mapView.region = .init(center: location, span: .init(latitudeDelta: span, longitudeDelta: span))
        }
    
    
    var editAltitude : Double = 0
    
    @IBAction func pushStepper(_ sender: UIStepper) {
        editAltitude = altitude + sender.value
        altitudeTextField.text = "\(editAltitude)"
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "MMddHHmmss"
        return formatter.string(from: date)
    }
    
    func buttonCheck(){
        print("\(isAnnotation) and \(imageIsSelected)")
        if isAnnotation && imageIsSelected {
            debugButton.isEnabled = true
        } else {
            debugButton.isEnabled = false
        }
    }
    
    @IBAction func pushButton(_ sender: Any) {
        if(isAnnotation && imageIsSelected){
            HUD.show(.progress, onView: view)
            let timestamp = Timestamp()
            let time = dateFormatterForDateLabel(date: timestamp.dateValue())
            
            let fileName = time + accessory.randomString(length: 20)
            
            print("ファイル名::::\(fileName)")
            
            accessory.savePostImageToFireStorege(selectedImage: selectedImage, fileName: fileName) {[weak self] result in
                switch result {
                    
                case .success((let rawUrl, let editedUrl)):
                    self?.postUploadModel.upload(postItem: .init(
                        areaId: Profile.shared.areaId,
                        genreId: "debug",
                        rawImageUrl: rawUrl,
                        editedImageUrl: editedUrl,
                        latitude: self?.pointAno.coordinate.latitude,
                        longitude: self?.pointAno.coordinate.longitude,
                        altitude: self?.editAltitude,
                        comment: self?.commentTextView.text,
                        imageStyle: 3,
                        id: fileName
                    )) {[weak self] result in
                        switch result {
                        case .success(_):
                            HUD.hide { (_) in
                                HUD.flash(.success, onView: self?.view, delay: 1) { (_) in
                                    print("投稿成功")
                                    self?.editAltitude = 0
                                    self?.altitudeTextField.text = "\(self?.altitude ?? 0)"
                                    self?.mapView.removeAnnotation((self?.pointAno)!)
                                    self?.isAnnotation = false
                                    self?.buttonCheck()
                                }
                            }
                            break
                        case .failure(let error):
                            HUD.hide { (_) in
                                HUD.flash(.label(error.domain), delay: 1.0) { _ in
                                    print("投稿失敗\(error)")
                                }
                            }
                        }
                    }
                case .failure(let error):
                    HUD.hide { (_) in
                        HUD.flash(.label(error.domain), delay: 1.0) { _ in
                            print("投稿失敗\(error)")
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func backView(_ sender: Any){
        print("push back image")
        //        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func mapViewLongTapped(_ sender: UILongPressGestureRecognizer){
        
        //TODO:  長押しじゃなくて通常タップでピンを配置できるようにする
        
        let location:CGPoint = sender.location(in: mapView)
        mapView.removeAnnotation(pointAno)
        isAnnotation = false
        buttonCheck()
        if (sender.state == .began){
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        if (sender.state == .ended){
            //タップした位置を緯度、経度の座標に変換する。
            let mapPoint:CLLocationCoordinate2D = mapView.convert(location,toCoordinateFrom: mapView)

            // 半径のメートル指定
            let radius: CLLocationDistance = 500
            let circularRegion = CLCircularRegion(center: center, radius: radius, identifier: "identifier")
            if circularRegion.contains(mapPoint) {
                // 含まれる
                //ピンを作成してマップビューに登録する。
                pointAno.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
                pointAno.title = "投稿予定位置"
                pointAno.subtitle = "\(pointAno.coordinate.latitude), \(pointAno.coordinate.longitude)"
                mapView.addAnnotation(pointAno)
                
                isAnnotation = true
                buttonCheck()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            // rendererを生成.
            let myCircleView: MKCircleRenderer = MKCircleRenderer(overlay: overlay)

            // 円の内部を赤色で塗りつぶす.
//            myCircleView.fillColor = UIColor.red

            // 円周の線の色を黒色に設定.
            myCircleView.strokeColor = UIColor.black

            // 円を透過させる.
            myCircleView.alpha = 0.5

            // 円周の線の太さ.
            myCircleView.lineWidth = 1.5

            return myCircleView
        }
    
    private func changeProfileImage(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
//        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func pushSelectImage(_ sender: Any) {
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
    
}

extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("呼ばれた")
        
        if let editImage = info[.editedImage] as? UIImage {
            selectedImage = editImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        imageIsSelected = true
        buttonCheck()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePicker closed")
        dismiss(animated: true)
        
    }
    
}



extension CreateNewPostViewController: MKMapViewDelegate{
    
}

extension CreateNewPostViewController: CLLocationManagerDelegate {

    
}

