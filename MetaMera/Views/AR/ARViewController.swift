//
//  ARViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/12.
//

import ARCL
import UIKit
import ARKit
import RealityKit
import MapKit
import SceneKit
import CoreLocation
import FirebaseCore
import FirebaseStorage
import AudioToolbox


class ARViewController: UIViewController, UITextFieldDelegate, ARSCNViewDelegate {
    
    //AR系
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var contentView: UIView!

    //多分いらなくなります
    //現在位置を表示するためのやつ
    @IBOutlet weak var textLabel: UILabel!
    //プロフィール画面に移行する用だけど多分プラスボタン系に結合されると思う
    @IBOutlet weak var ProfileImage: UIImageView!
    
    //プラスボタン系
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var selectCategoryButton: UIButton!
    
    
    //プラスボタンを長押しした時用のやつ
    private lazy var plusButtonLongTapGuester: UILongPressGestureRecognizer = {
        let guester = UILongPressGestureRecognizer(target: self, action: #selector(plusButtonLongTapped(_:)))
        return guester
    }()
    
    //ループ用のやつ
    var updateInfoLabelTimer: Timer?
    
    //AR系2
    var sceneLocationView = SceneLocationView()
    var locationManager = CLLocationManager()
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面遷移した時だけ現在位置を表示するためにTrueにするよ
        flag = true
        
        // プラスボタンにタップジェスチャー追加
        plusButton.addGestureRecognizer(plusButtonLongTapGuester)
        
        // Load the "Box" scene from the "Experience" Reality File
        
        do {
            let boxAnchor = try Experience.loadBox()
            //arView.scene.anchors.append(boxAnchor)
            //sceneLocationView
        }catch {
            print("error")
        }
        
        //MARK: プロフィール画像
        ProfileImage.layer.cornerRadius = 25
        ProfileImage.isUserInteractionEnabled = true
        ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushProfileImage(_:))))
        
        //MARK: プラスボタン系
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(backTap))
        self.backView.addGestureRecognizer(tapGestureRecognizer)
        
        
        plusButton.imageView?.contentMode = .scaleAspectFill
        profileButton.imageView?.contentMode = .scaleAspectFill
        createRoomButton.imageView?.contentMode = .scaleAspectFill
        selectCategoryButton.imageView?.contentMode = .scaleAspectFill

        plusButton.contentHorizontalAlignment = .fill
        profileButton.contentHorizontalAlignment = .fill
        createRoomButton.contentHorizontalAlignment = .fill
        selectCategoryButton.contentHorizontalAlignment = .fill

        plusButton.contentVerticalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill
        createRoomButton.contentVerticalAlignment = .fill
        selectCategoryButton.contentVerticalAlignment = .fill
        
        plusButton.contentHorizontalAlignment = .center
        
        plusButton.layer.cornerRadius = 50
        profileButton.layer.cornerRadius = 30
        createRoomButton.layer.cornerRadius = 30
        selectCategoryButton.layer.cornerRadius = 30
        
        
        
        
        //MARK: 位置情報のやつっぽい
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
//        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        locationManager.requestWhenInUseAuthorization()
    
        mapView.showsUserLocation = true
        
        // MARK: - ここからARのやつのやつ
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.pauseAnimation()
        }
        // swiftlint:disable:next discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.restartAnimation()
        }
        
        
        
        sceneLocationView.showAxesNode = false
        sceneLocationView.locationNodeTouchDelegate = self
//        sceneLocationView.delegate = self // Causes an assertionFailure - use the `arViewDelegate` instead:
        sceneLocationView.arViewDelegate = self
        sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.orientToTrueNorth = false
        
        
        
        addSceneModels()
        
//        var num = 0
//        Profile.shared.nodeLocationsLatitude.forEach { latitude in
////            let coordinate
//            print("num:       ",num)
//            let pin = MKPointAnnotation()
//            pin.title = "テストピン"
//            pin.subtitle = "サブタイトル"
//            pin.coordinate = CLLocationCoordinate2DMake(latitude, Profile.shared.nodeLocationsLongitude[num])
//            num+=1
//            mapView.addAnnotation(pin)
//        }
        
        //36.35801663766492, 138.63498898207519
        let pin = MKPointAnnotation()
        pin.title = "テストピン"
        pin.subtitle = "サブタイトル"
        pin.coordinate = CLLocationCoordinate2DMake(36.35801663766492, 138.63498898207519)
        mapView.addAnnotation(pin)
        
        
//        sceneLocationView.run()
        contentView.addSubview(sceneLocationView)
        
        sceneLocationView.frame = .zero
        
//        sceneLocationView.run()
        
        // Do any additional setup after loading the view.
        
        updateInfoLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateInfoLabel()
        }
    }
    
    
    //    override var inputAccessoryView: UIView? {
    //        get {
    //            return chatView
    //        }
    //    }
    //
    //    override var canBecomeFirstResponder: Bool {
    //        return true
    //    }
    //
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        self.view.endEditing(true)
    //    }
    
    //MARK: わかんない！
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Profile.shared.updateProfileImage() {
        case .success(let image):
            ProfileImage.image = image
        case .failure(let error):
            break
        }
        
        //MARK: ナビゲーションコントローラーを隠すよ！
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        restartAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAnimation()
    }
    
    //MARK: - プロフィール画像関連
    
    //MARK: プロフィール画面に遷移するよ！
    @objc func pushProfileImage(_ sender: Any){
        print("Push profile image")
        Goto.Profile(view: self)
    }
    
    //MARK: プロフィール画像関連 -
    
    
    // MARK: - ここからAR
    
    //MARK: ARを止めるよ！
    func pauseAnimation() {
        print("pause")
        sceneLocationView.pause()
    }
    
    //MARK: ARを再開するよ！
    func restartAnimation() {
        sceneLocationView.isPlaying = true
        DispatchQueue.main.async { [weak self] in
            
            print("run")
            self?.sceneLocationView.run()
        }
        
    }
    
    //MARK: ここで座標に基づいたオブジェクトを設置してるよ
    func buildDemoData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        
        //        let canaryWharf = buildNode(latitude: 35.625318, longitude: 139.341903, altitude: 100, imageName: "pin")
        //        nodes.append(canaryWharf)
        
        //        let applePark = buildViewNode(latitude: 35.625835, longitude: 139.341659, altitude: 200, text: "広場", color: UIColor.red)
        //        nodes.append(applePark)
        
        let pikesPeakLayer = CATextLayer()
        pikesPeakLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        pikesPeakLayer.cornerRadius = 4
        pikesPeakLayer.fontSize = 14
        pikesPeakLayer.alignmentMode = .center
        pikesPeakLayer.foregroundColor = UIColor.black.cgColor
        pikesPeakLayer.backgroundColor = UIColor.white.cgColor
        
        // This demo uses a simple periodic timer to showcase dynamic text in a node.  In your implementation,
        // the view's content will probably be changed as the result of a network fetch or some other asynchronous event.
        
        //        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        //            pikesPeakLayer.string = "Pike's Peak\n" + Date().description
        //        }
        //
        //        let pikesPeak = buildLayerNode(latitude: 38.8405322, longitude: -105.0442048, altitude: 4705, layer: pikesPeakLayer)
        //        nodes.append(pikesPeak)
        
//        let applePark1 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 200, text: "200", color: UIColor.green)
//        nodes.append(applePark1)
//        let applePark2 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 210, text: "210", color: UIColor.green)
//        nodes.append(applePark2)
//        let applePark3 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 230, text: "230", color: UIColor.green)
//        nodes.append(applePark3)
//        let applePark4 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 280, text: "280", color: UIColor.green)
//        nodes.append(applePark4)
//        let applePark5 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 290, text: "290", color: UIColor.green)
//        nodes.append(applePark5)
//        let applePark6 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 310, text: "310", color: UIColor.green)
//        nodes.append(applePark6)
//        let applePark7 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 320, text: "320", color: UIColor.green)
//        nodes.append(applePark7)
//
//        let applePark8 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 190, text: "190", color: UIColor.green)
//        nodes.append(applePark8)
//        let applePark9 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 180, text: "180", color: UIColor.green)
//        nodes.append(applePark9)
//        let applePark10 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 170, text: "170", color: UIColor.green)
//        nodes.append(applePark10)
//        let applePark11 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 160, text: "160", color: UIColor.green)
//        nodes.append(applePark11)
//        let applePark12 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 150, text: "150", color: UIColor.green)
//        nodes.append(applePark12)
//        let applePark13 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 140, text: "140", color: UIColor.green)
//        nodes.append(applePark13)
//        let applePark14 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 130, text: "130", color: UIColor.green)
//        nodes.append(applePark14)
//        let applePark15 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 120, text: "120", color: UIColor.green)
//        nodes.append(applePark15)
//        let applePark16 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 110, text: "110", color: UIColor.green)
//        nodes.append(applePark16)
//        let applePark17 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 100, text: "100", color: UIColor.green)
//        nodes.append(applePark17)
        
        let spaceNeedle = buildNode(latitude: 35.624929, longitude: 139.341696, altitude: 175, imageName: "drink",size: CGSize(width: 400, height: 300))
//        spaceNeedle.scaleRelativeToDistance = true
        spaceNeedle.tag = "drink"
        nodes.append(spaceNeedle)
        
        let nike = buildNode(latitude: 35.70561533774642, longitude: 139.57692592332617, altitude: 175, imageName: "shoes",size: CGSize(width: 400, height: 300))
        nike.scaleRelativeToDistance = true
        nodes.append(nike)
        
//        36.35801663766492, 138.63498898207519
        
        let karuizawa = buildNode(latitude: 36.35801663766492, longitude: 138.63498898207519, altitude: 1000, imageName: "snow",size: CGSize(width: 200, height: 300))
//        karuizawa.scaleRelativeToDistance = true
        nodes.append(karuizawa)
        
//        35.62510858464141, 139.24366875641377
        
        let takaosan = buildNode(latitude: 35.62510858464141, longitude: 139.24366875641377, altitude: 610, imageName: "road",size: CGSize(width: 200, height: 300))
        takaosan.scaleRelativeToDistance = true
        nodes.append(takaosan)
        
        
        let spaceNeedle4 = buildNode(latitude: 35.625050, longitude: 139.3418137, altitude: 180, imageName: "train",size: CGSize(width: 200, height: 300))
        spaceNeedle4.scaleRelativeToDistance = true
        nodes.append(spaceNeedle4)
        
        
        return nodes
    }
    
    //MARK: まだ勉強してるよ！
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }
        
        buildDemoData().forEach {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
            sceneLocationView.moveSceneHeadingAntiClockwise()
//            sceneLocationView.moveSceneHeadingClockwise()
        }
        
        //        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        //        cubeNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
        
        //        sceneLocationView.scene.rootNode.addChildNode(cubeNode)
        
        // There are many different ways to add lighting to a scene, but even this mechanism (the absolute simplest)
        // keeps 3D objects fron looking flat
        sceneLocationView.autoenablesDefaultLighting = true
        //sceneLocationView.useTrueNorth = false
        
        
    }
    
    
    
    //MARK: - ここからオブジェクトを生成するためのやつだよ

    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance,
                   imageName: String, size: CGSize) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let pin = MKPointAnnotation()
        pin.title = imageName
        pin.subtitle = "高さ:"+String(altitude)
        pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mapView.addAnnotation(pin)
        let annotation = MKPointAnnotation()
        guard let image = UIImage(named: imageName)?.reSizeImage(reSize: size) else
        {
            let image = UIImage(named: imageName)!
            image.accessibilityIdentifier = imageName
//            Profile.shared.nodeLocationsLatitude.append(latitude)
//            Profile.shared.nodeLocationsLongitude.append(longitude)
            
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            annotation.title = imageName
            annotation.subtitle = "高さ"+String(altitude)
            mapView.addAnnotation(annotation)
            return LocationAnnotationNode(location: location, image: image)
            
        }
        image.accessibilityIdentifier = imageName
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.title = imageName
        annotation.subtitle = "高さ"+String(altitude)
        mapView.addAnnotation(annotation)
        return LocationAnnotationNode(location: location, image: image)
    }
    
    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String, color: UIColor) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = text
        label.backgroundColor = color
        label.textAlignment = .center
        return LocationAnnotationNode(location: location, view: label)
    }
    
    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String, color: UIColor, d3Object: SCNNode) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = text
        label.backgroundColor = color
        label.textAlignment = .center
        return LocationAnnotationNode(location: location, view: label)
    }
    
    func buildLayerNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                        altitude: CLLocationDistance, layer: CALayer) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        return LocationAnnotationNode(location: location, layer: layer)
    }
    
    @objc
    func updateInfoLabel() {
        if let eulerAngles = sceneLocationView.currentEulerAngles,
           let heading = sceneLocationView.sceneLocationManager.locationManager.heading,
           let headingAccuracy = sceneLocationView.sceneLocationManager.locationManager.headingAccuracy {
            let yDegrees = (((0 - eulerAngles.y.radiansToDegrees) + 360).truncatingRemainder(dividingBy: 360) ).short
            textLabel.text = " Heading: \(yDegrees)° • \(Float(heading).short)° • \(headingAccuracy)°"
        }
    }
    //MARK: ここまでオブジェクトを生成するためのやつだよ -
    //MARK: - プラスボタンのやつ
    
    /// プラスボタン選択時
    private var isSettingShowing: Bool = false
    @objc func plusButtonLongTapped(_ sender: Any) {
        if !isSettingShowing {
            
            
            //振動
            AudioServicesPlaySystemSound(1519)
//            AudioServicesPlaySystemSound(1001)
//            AudioServicesPlaySystemSound(1519)
            // 背景設定
            backView.alpha = 0
            backView.isHidden = false
            // プラスボタン非表示
            plusButton.isHidden = true
            // 選択ボタン表示
            profileButton.isHidden = false
            selectCategoryButton.isHidden = false
            createRoomButton.isHidden = false
            // 表示切り替えアニメーション
            UIView.animate(
                withDuration: 0.1,
                delay: 0.2,
                options: .curveEaseOut,
                animations: { [weak self] () in
                    // プロフィールボタン
                    self?.profileButton.center.y -= 100.0
                    self?.profileButton.center.x -= 10.0
                    // カテゴリ選択ボタン
                    self?.selectCategoryButton.center.x += 80.0
                    self?.selectCategoryButton.center.y += 20.0
                    // ルーム作成ボタン
                    self?.createRoomButton.center.x += 60.0
                    self?.createRoomButton.center.y -= 60.0
                    // 背景
                    self?.backView.alpha += 0.5
                    
                    self?.isSettingShowing = true
                }
            )
        }
        
    }
    
    @IBAction func pushPlusButton(_ sender: Any) {
        print("plus 普通のタップ")
    }
    
    @objc func backTap(){
        
        profileButton.layer.position = plusButton.layer.position
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] () in
            
            self?.profileButton.layer.position = self!.plusButton.layer.position
            
            // プロフィールボタン
            self?.profileButton.center.y += 100.0
            self?.profileButton.center.x += 10.0
            // カテゴリ選択ボタン
            self?.selectCategoryButton.center.x -= 80.0
            self?.selectCategoryButton.center.y -= 20.0
            // ルーム作成ボタン
            self?.createRoomButton.center.x -= 60.0
            self?.createRoomButton.center.y += 60.0
        }, completion: { [weak self] (Bool) in
            // 背景設定
            self?.backView.isHidden = true
            // プラスボタン非表示
            self?.plusButton.isHidden = false
            // 選択ボタン表示
            self?.profileButton.isHidden = true
            self?.selectCategoryButton.isHidden = true
            self?.createRoomButton.isHidden = true
            self?.isSettingShowing = false
        })
    }
    
    @IBAction func pushProfileButton(_ sender: Any) {
        backTap()
        Goto.ChatRoom(view: self, image: UIImage(named: "drink")!)
    }
    
    @IBAction func pushCreateRoom(_ sender: Any) {
        
    }
    
    @IBAction func pushSelectCategory(_ sender: Any) {
        
    }
    
    
    
    //MARK: プラスボタンのやつ -
    
    
}


//MARK: ARのオブジェクトをタップしたときに呼び出される
extension ARViewController: LNTouchDelegate {
    func annotationNodeTouched(node: AnnotationNode) {
        print("[tapEvent]: ", node.view?.tag as Any)
        print("[findNodes]: ", sceneLocationView.findNodes(tagged: "drink"))
        if let nodeView = node.view{
            // Do stuffs with the nodeView
            // ...
            
            print("[nodeView]: ",nodeView)
        }
        if let nodeImage = node.image{
            // Do stuffs with the nodeImage
            // ...
            print("[nodeImage: getName]", nodeImage.accessibilityIdentifier ?? "null")
            Goto.ChatRoom(view: self, image: node.image!)
        }
        
    }
    
    func locationNodeTouched(node: LocationNode) {
        guard let name = node.tag else { return }
        guard let selectedNode = node.childNodes.first(where: { $0.geometry is SCNBox }) else { return }
        
        print("name: "+name)
        print("selectedNode: ",selectedNode)
    }
    
    
}

extension UIImageView {
    func getFileName() -> String? {
        return self.image?.accessibilityIdentifier
    }
}

//MARK: Imageのサイズを変更する
extension UIImage {
    
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}


//MARK: 位置情報のやつ
var flag: Bool = true
extension ARViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.map { $0.coordinate })
        if let location = manager.location?.coordinate {
            let center: CLLocationCoordinate2D = .init(latitude: location.latitude, longitude: location.longitude)
            if flag {
                mapView.region = .init(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapView.centerCoordinate = center
                flag.toggle()
            }
        }
    }
}
