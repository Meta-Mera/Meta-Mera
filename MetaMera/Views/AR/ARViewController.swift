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
import Firebase
import AudioToolbox
import Nuke


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
    @IBOutlet weak var plusLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var profileLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var createRoomLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var createRoomBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var selectCategoryLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCategoryBottomConstraint: NSLayoutConstraint!
    
    
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

        configView()
        setUpPlusButtons()
        enableAutoLayout()
        saveDefaultButtonPosision()
        moveMenuButtonPosision()
        hiddenButton()
    }
    
    func configView(){
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //画面遷移した時だけ現在位置を表示するためにTrueにするよ
        flag = true
        
        // Load the "Box" scene from the "Experience" Reality File
        
        do {
            let boxAnchor = try Experience.loadBox()
            //arView.scene.anchors.append(boxAnchor)
            //sceneLocationView
        }catch {
            print("error")
        }
        
        
        //MARK: 位置情報のやつっぽい
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
//        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    
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
    
    func setUpPlusButtons(){
        
        // プラスボタンにタップジェスチャー追加
        plusButton.addGestureRecognizer(plusButtonLongTapGuester)
        
        //MARK: プロフィール画像
        ProfileImage.layer.cornerRadius = 25
        ProfileImage.isUserInteractionEnabled = true
        ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushProfileImage(_:))))
        
        self.view.bringSubviewToFront(selectCategoryButton)
        self.view.bringSubviewToFront(createRoomButton)
        self.view.bringSubviewToFront(plusButton)
        self.view.bringSubviewToFront(profileButton)
        
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
        
        plusButton.imageView?.layer.cornerRadius = plusButton.bounds.width / 2
        profileButton.imageView?.layer.cornerRadius = profileButton.bounds.width / 2
        createRoomButton.imageView?.layer.cornerRadius = createRoomButton.bounds.width / 2
        selectCategoryButton.imageView?.layer.cornerRadius = selectCategoryButton.bounds.width / 2
        
        let borderWidthInt : CGFloat = 3
        let borderColor : CGColor = UIColor.rgb(red: 120, green: 200, blue: 255).cgColor
        
        plusButton.imageView?.layer.borderWidth = borderWidthInt
        profileButton.imageView?.layer.borderWidth = borderWidthInt
        createRoomButton.imageView?.layer.borderWidth = borderWidthInt
        selectCategoryButton.imageView?.layer.borderWidth = borderWidthInt
        
        plusButton.imageView?.layer.borderColor = borderColor
        profileButton.imageView?.layer.borderColor = borderColor
        createRoomButton.imageView?.layer.borderColor = borderColor
        selectCategoryButton.imageView?.layer.borderColor = borderColor
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Profile.shared.isLogin == false {
            print("呼ばれた: ",Profile.shared.isLogin!)
            sleep(1)
            self.dismiss(animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Profile.shared.updateProfileImage() {
        case .success(let image):
            ProfileImage.setImage(image: image, name: Profile.shared.loginUser.uid)
//            ProfileImage.image = image
//            ProfileImage.setImage(url: Profile.shared.userIconImageUrl, name: Profile.shared.userId)
        case .failure(_):
            break
        }
        
        //MARK: ナビゲーションコントローラーを隠すよ！
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        restartAnimation()
        
        //MARK: 位置情報から[市区町村名、郵便番号、関心のあるエリア名]のうち取得できたものを表示します。
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                guard let placemark = placemarks?.first, error == nil else { return }
                
                if let locality = placemark.locality {
                    print("locality: ",locality as Any)
                }
                
                if let postalCode = placemark.postalCode {
                    print("postalCode: ",postalCode as Any)
                }
                if let areasOfInterest = placemark.areasOfInterest {
                    print("areasOfInterest: ",areasOfInterest)
                }
            })
        }
        
        //MARK: 端末に保存してあるデータを表示するためのやつ
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let contentUrls = try FileManager.default.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil)
            let files = contentUrls.map{$0.lastPathComponent}
            print("files:   ",files) //-> ["test1.txt", "test2.txt"]
        } catch {
            print(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAnimation()
    }
    
    //MARK: - プロフィール画像関連
    
    //MARK: プロフィール画面に遷移するよ！
    @objc func pushProfileImage(_ sender: Any){
        print("getName: ",ProfileImage.getName() as Any)
        print("Push profile image")
        Goto.Profile(view: self, user: Profile.shared.loginUser)
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
        
        let pikesPeakLayer = CATextLayer()
        pikesPeakLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        pikesPeakLayer.cornerRadius = 4
        pikesPeakLayer.fontSize = 14
        pikesPeakLayer.alignmentMode = .center
        pikesPeakLayer.foregroundColor = UIColor.black.cgColor
        pikesPeakLayer.backgroundColor = UIColor.white.cgColor
        
        let spaceNeedle = buildNode(latitude: 35.624929, longitude: 139.341696, altitude: 175, imageName: "drink",size: CGSize(width: 400, height: 300), pinUse: false)
//        spaceNeedle.scaleRelativeToDistance = true
        spaceNeedle.tag = "drink"
//        nodes.append(spaceNeedle)
        
        let nike = buildNode(latitude: 35.70561533774642, longitude: 139.57692592332617, altitude: 175, imageName: "shoes",size: CGSize(width: 400, height: 300), pinUse: true, pinName: "shoes", postId: "test")
        nike.scaleRelativeToDistance = true
        nodes.append(nike)
        
//        36.35801663766492, 138.63498898207519
        
        let karuizawa = buildNode(latitude: 36.35801663766492, longitude: 138.63498898207519, altitude: 1000, imageName: "snow",size: CGSize(width: 200, height: 300), pinUse: true, pinName: "snow", postId: "test")
        karuizawa.scaleRelativeToDistance = true
        nodes.append(karuizawa)
        
//        35.62510858464141, 139.24366875641377
        
        let takaosan = buildNode(latitude: 35.62510858464141, longitude: 139.24366875641377, altitude: 610, imageName: "road",size: CGSize(width: 200, height: 300), pinUse: true, pinName: "road", postId: "test")
        takaosan.scaleRelativeToDistance = true
//        takaosan.tag = "test"
        nodes.append(takaosan)
        
//        35.62477445850865, 139.3414411733747
        
        
        let arufoto = buildNode(latitude: 35.62477445850865, longitude: 139.3414411733747, altitude: 190, imageName: "ソルトアルフォート",size: CGSize(width: 278, height: 122), pinUse: true, pinName: "アルフォート",postId: "Uz93q4hTLBHvLUFglhxp")
        arufoto.tag = "test"
//        arufoto.scaleRelativeToDistance = true
        nodes.append(arufoto)
        
        
        let spaceNeedle4 = buildNode(latitude: 35.625050, longitude: 139.3418137, altitude: 180, imageName: "train",size: CGSize(width: 200, height: 300), pinUse: false)
        spaceNeedle4.scaleRelativeToDistance = true
        nodes.append(spaceNeedle4)
        
        
        return nodes
    }
    
    func buildNodeData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        
        //35.75444876559928, 139.4811042224357
        
        let takaosan = buildNode(latitude: 35.75444876559928, longitude: 139.4811042224357, altitude: 100, imageName: "road",size: CGSize(width: 200, height: 300), pinUse: true, pinName: "road",postId: "test")
//        takaosan.scaleRelativeToDistance = true
        nodes.append(takaosan)

        return nodes
    }
    
    //MARK: - ここからわからん
    
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
//            sceneLocationView.moveSceneHeadingAntiClockwise()
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
    
    var annotationArray: [MKAnnotation] = []
    
    
    
    //MARK: - ここからオブジェクトを生成するためのやつだよ

    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance,
                   imageName: String, size: CGSize,
                   pinUse: Bool, pinName: String,
                   postId: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let annotation = MKPointAnnotation()
        guard let image = UIImage(named: imageName)?.reSizeImage(reSize: size) else
        {
            let image = UIImage(named: imageName)!
            image.accessibilityIdentifier = postId
            print("---------------------------------------")
            print("accessibilityIdentifier: ",image.accessibilityIdentifier as Any)
            print("---------------------------------------")
//            Profile.shared.nodeLocationsLatitude.append(latitude)
//            Profile.shared.nodeLocationsLongitude.append(longitude)
            if pinUse {
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                annotation.title = pinName
                annotation.subtitle = "高さ"+String(altitude)
                annotationArray.append(annotation)
                mapView.addAnnotation(annotation)
            }
            return LocationAnnotationNode(location: location, image: image)
            
        }
        image.accessibilityIdentifier = postId
        print("---------------------------------------")
        print("accessibilityIdentifier: ",image.accessibilityIdentifier as Any)
        print("---------------------------------------")
        if pinUse {
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            annotation.title = pinName
            annotation.subtitle = "高さ"+String(altitude)
            annotationArray.append(annotation)
            mapView.addAnnotation(annotation)
        }
        return LocationAnnotationNode(location: location, image: image)
    }
    
    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance,
                   imageName: String, size: CGSize,
                   pinUse: Bool = false) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let annotation = MKPointAnnotation()
        guard let image = UIImage(named: imageName)?.reSizeImage(reSize: size) else
        {
            let image = UIImage(named: imageName)!
            image.accessibilityIdentifier = imageName
            print("---------------------------------------")
            print("accessibilityIdentifier: ",image.accessibilityIdentifier as Any)
            print("---------------------------------------")
//            Profile.shared.nodeLocationsLatitude.append(latitude)
//            Profile.shared.nodeLocationsLongitude.append(longitude)
            return LocationAnnotationNode(location: location, image: image)
            
        }
        image.accessibilityIdentifier = imageName
        print("---------------------------------------")
        print("accessibilityIdentifier: ",image.accessibilityIdentifier as Any)
        print("---------------------------------------")
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
            textLabel.isHidden = true
        }
    }
    
    @objc func addNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance,
                       imageName: String, size: CGSize,
                       pinUse: Bool, pinName: String,
                       postId: String){
        let node = buildNode(latitude: latitude, longitude: longitude, altitude: altitude, imageName: imageName, size: size, pinUse: pinUse, pinName: pinName, postId: postId)
        node.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: node)
    }
    //MARK: ここまでオブジェクトを生成するためのやつだよ -
    
    
    //MARK: ここまでわからん -
    
    
    
    
    //MARK: - プラスボタンのやつ(90%)
    
    var profileButtonCenter: CGPoint!
    var selectCategoryButtonCenter: CGPoint!
    var createRoomButtonCenter: CGPoint!
    
    private func enableAutoLayout(){
        profileButton.translatesAutoresizingMaskIntoConstraints = true
        selectCategoryButton.translatesAutoresizingMaskIntoConstraints = true
        createRoomButton.translatesAutoresizingMaskIntoConstraints = true
        plusButton.translatesAutoresizingMaskIntoConstraints = true
    }
    
    private func showButton(){
        self.profileButton.alpha = 1
        self.selectCategoryButton.alpha = 1
        self.createRoomButton.alpha = 1
    }
    
    private func hiddenButton(){
        self.profileButton.alpha = 0
        self.selectCategoryButton.alpha = 0
        self.createRoomButton.alpha = 0
    }
    
    private func saveDefaultButtonPosision() {
        profileButtonCenter = profileButton.center
        selectCategoryButtonCenter = selectCategoryButton.center
        createRoomButtonCenter = createRoomButton.center
    }
    
    /// ボタンを元の場所に移動する
    private func moveDefaultButtonPosision() {
        profileButton.center = profileButtonCenter
        selectCategoryButton.center = selectCategoryButtonCenter
        createRoomButton.center = createRoomButtonCenter
    }
    
    /// ボタンをメニューの場所へ移動する
    private func moveMenuButtonPosision() {
        profileButton.center = plusButton.center
        selectCategoryButton.center = plusButton.center
        createRoomButton.center = plusButton.center
    }
    
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
            
            UIView.animate(
                withDuration: 0.3,
                animations: { [weak self] () in
                    self?.backView.alpha = 0.5
                    self?.moveDefaultButtonPosision()
                    self?.showButton()
                    self?.isSettingShowing = true
            })
        }
        
    }
    
    @IBAction func pushPlusButton(_ sender: Any) {
        print("plus 普通のタップ")
        Goto.CreateNewPost(view: self)
    }
    
    @objc func backTap(){
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] () in
                
                self?.moveMenuButtonPosision()
                self?.hiddenButton()
//                self?.backView.isHidden = true
                self?.backView.alpha = 0
                self?.isSettingShowing = false
                self?.plusButton.isHidden = false
            })
    }
    
    @IBAction func pushProfileButton(_ sender: Any) {
        backTap()
//        Goto.ChatRoom(view: self, image: UIImage(named: "drink")!)
//        Goto.Profile(view: self)
        sceneLocationView.removeAllNodes()
        mapView.removeAnnotations(annotationArray)
//        addNode(latitude: 35.75444876559928, longitude: 139.4811042224357, altitude: 170, imageName: "road",size: CGSize(width: 200, height: 300), pinUse: true, pinName: "road", postId: "test")
        
        //35.62473923766413, 139.34178926227506
        
        addNode(latitude: 35.62473923766413, longitude: 139.34178926227506, altitude: 180, imageName: "ソルトアルフォート",size: CGSize(width: 278, height: 122), pinUse: true, pinName: "ソルトアルフォート", postId: "Uz93q4hTLBHvLUFglhxp")
        
        //35.62469213276725, 139.34172279611786
        
        addNode(latitude: 35.62469213276725, longitude: 139.34172279611786, altitude: 180, imageName: "ブラックアルフォート",size: CGSize(width: 278, height: 122), pinUse: true, pinName: "ブラックアルフォート", postId: "Uz93q4hTLBHvLUFglhxp")
        
        //35.62466634430945, 139.3416535268315
        
        addNode(latitude: 35.62466634430945, longitude: 139.3416535268315, altitude: 180, imageName: "ホワイトアルフォート",size: CGSize(width: 278, height: 122), pinUse: true, pinName: "ホワイトアルフォート", postId: "Uz93q4hTLBHvLUFglhxp")
        
        //35.624671229322196, 139.34164661220515
        
        addNode(latitude: 35.624671229322196, longitude: 139.34164661220515, altitude: 180, imageName: "ブルーアルフォート",size: CGSize(width: 400, height: 600), pinUse: true, pinName: "ブルーアルフォート", postId: "Uz93q4hTLBHvLUFglhxp")
    }
    
    @IBAction func pushCreateRoom(_ sender: Any) {
        backTap()
        Firestore.firestore().collection("Posts").document("Uz93q4hTLBHvLUFglhxp").getDocument { (snapshot, err) in
            if let err = err {
                print("投稿情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let dic = snapshot?.data() else { return }
            print("投稿情報の取得に成功しました。")
            let post = Post(dic: dic,postId: "Uz93q4hTLBHvLUFglhxp")
            print(post.createdAt.dateValue())
            Goto.ChatRoomView(view: self, image: UIImage(named: "katsu")!, post: post)
        }
        
    }
    
    @IBAction func pushSelectCategory(_ sender: Any) {
        backTap()
        
    }
    //MARK: プラスボタンのやつ(90%) -
    
    
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
            
//            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let selectImage = nodeImage.accessibilityIdentifier else { return }
            
            //TODO: チャットルームを渡す方法を考える
            Firestore.firestore().collection("Posts").document(selectImage).getDocument { (snapshot, err) in
                if let err = err {
                    print("投稿情報の取得に失敗しました。\(err)")
                    return
                }
                
                guard let dic = snapshot?.data() else { return }
                let post = Post(dic: dic, postId: selectImage)
                Goto.ChatRoomView(view: self, image: node.image!, post: post)
            }
//            Goto.ChatRoomView(view: self, image: node.image!, chatroomId: chatroom)
//            Goto.PostView(view: self, image: node.image!, chatroomId: selectImage)
        }
        
    }
    
    func locationNodeTouched(node: LocationNode) {
        guard let name = node.tag else { return }
        guard let selectedNode = node.childNodes.first(where: { $0.geometry is SCNBox }) else { return }
        
        print("name: "+name)
        print("selectedNode: ",selectedNode)
    }
    
    
}

extension ARViewController: SignOutProtocol {
    
    func signOut(check: Bool) {
        let signOutcheck = check
        if signOutcheck {
            self.dismiss(animated: true)
        }
    }
    
}


//MARK: 位置情報のやつ
var flag: Bool = true
extension ARViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.map { $0.coordinate })
        if let location = manager.location?.coordinate {
            let center: CLLocationCoordinate2D = .init(latitude: location.latitude, longitude: location.longitude)
//            mapView.userTrackingMode = .follow
            mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
            if flag {
                mapView.region = .init(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapView.centerCoordinate = center
                mapView.userTrackingMode = .followWithHeading
                flag.toggle()
            }
        }
    }
}
