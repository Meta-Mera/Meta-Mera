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
import Alamofire
import AlamofireImage


class ARViewController: UIViewController, UITextFieldDelegate, ARSCNViewDelegate {
    
    //AR系
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var contentView: UIView!
    
    //多分いらなくなります
    //現在位置を表示するためのやつ
    @IBOutlet weak var textLabel: UILabel!
    //プロフィール画面に移行する用だけど多分プラスボタン系に結合されると思う
    @IBOutlet weak var ProfileImage: UIImageView!
    
    //MARK: -プラスボタン系
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var selectCategoryButton: UIButton!
    
    //MARK: -プラスボタン系
    
    
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
    
    //投稿リスト
    var posts : [Post]?
    
    //市区町村名とか
    var locality : String?
    
    
    
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posts = [Post]()
        
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
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        // MARK: - ここからARのやつのやつ
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.pauseAnimation()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.restartAnimation()
        }
        
        
        
        sceneLocationView.showAxesNode = false
        sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.arViewDelegate = self
        sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.orientToTrueNorth = false
        
        
        
        addSceneModels()
        
        let pin = MKPointAnnotation()
        pin.title = "テストピン"
        pin.subtitle = "サブタイトル"
        pin.accessibilityValue = "tesofihasdfoihasdofhasdoift"
        MKPointAnnotation.description()
        pin.coordinate = CLLocationCoordinate2DMake(36.35801663766492, 138.63498898207519)
        mapView.addAnnotation(pin)
        
        
        contentView.addSubview(sceneLocationView)
        
        sceneLocationView.frame = .zero
        
        updateInfoLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateInfoLabel()
        }
        
    }
    
    func setUpPlusButtons(){
        
        
        //MARK: プロフィール画像
        ProfileImage.layer.cornerRadius = ProfileImage.bounds.width / 2
        ProfileImage.isUserInteractionEnabled = true
        ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushProfileImage(_:))))
        
        //MARK: - プラスボタン系
        
        // プラスボタンにタップジェスチャー追加
        plusButton.addGestureRecognizer(plusButtonLongTapGuester)
        
        self.view.bringSubviewToFront(selectCategoryButton)
        self.view.bringSubviewToFront(createRoomButton)
        self.view.bringSubviewToFront(plusButton)
        self.view.bringSubviewToFront(profileButton)
        
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
        
        //MARK: プラスボタン系 -
        
    }
    
    //MARK: わかんない！
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Profile.shared.isLogin == false {
            print("呼ばれた: ",Profile.shared.isLogin!)
            self.dismiss(animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Profile.shared.updateProfileImage() {
        case .success(let image):
            ProfileImage.setImage(image: image, name: Profile.shared.loginUser.uid)
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
                                            completionHandler: { [weak self] (placemarks, error) in
                guard let placemark = placemarks?.first, error == nil else { return }
                
                if let locality = placemark.locality {
                    self?.locality = locality
                    print("locality: ",locality as Any)
                    Firestore.firestore().collection("Areas").whereField("areaName", isEqualTo: locality).getDocuments(completion: { [weak self]
                        (snapshot, error) in
                        let language = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first
                        
                        print("🐱: \(String(describing: language))") // 🐱: Optional("ja")
                        if let error = error {
                            print("Error getting documents: \(error)")
                        }else {
                            
                            print("data count:\(snapshot!.count)")
                            guard snapshot!.documents.first?.data().first?.value != nil else {
                                print("データなし")
                                let docData = ["areaName": locality,
                                               "areaId" : "null"] as [String : Any]
                                var ref: DocumentReference? = nil
                                let areaRef = Firestore.firestore().collection("Areas")
                                
                                ref = areaRef.addDocument(data: docData) { (err) in
                                    if let err = err {
                                        print("FirestoreにareaIdの登録ができませんでした。\(err)")
                                        return
                                    } else {
                                        let docId = ref!.documentID
                                        print("DocumentID:\(docId)")
                                        
                                        let updateRef = Firestore.firestore().collection("Areas").document(docId)
                                        
                                        // Set the "capital" field of the city 'DC'
                                        updateRef.updateData([
                                            "areaId": docId
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            } else {
                                                print("areaIdの保存に成功！！")
                                                Profile.shared.areaId = docId
                                            }
                                        }
                                    }
                                }
                                return
                            }
                            
                            let areaIds = AreaId(dic: snapshot!.documents.first!.data())
                            let areaId = areaIds.areaId
                            Profile.shared.areaId = areaId
                            Firestore.firestore().collection("Posts").whereField("areaId", isEqualTo: areaId as Any).getDocuments(completion: {
                                (postSnapshots, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                }else {
                                    for document in postSnapshots!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let post = Post(dic: document.data(), postId: document.documentID)
                                        if !post.deleted && !post.hidden {
                                            self?.posts?.append(post)
                                        }
                                        
                                        
                                    }
                                    self?.addSceneModels()
                                }
                            })
                        }
                    })
                    
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
    
    func buildPostData(completion: @escaping([LocationAnnotationNode]) -> Void) {
        var nodes: [LocationAnnotationNode] = []
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "appendNode")
        
        
        posts?.forEach({ post in
            
            dispatchGroup.enter()
            dispatchQueue.async {
                var imageStyle: CGSize
                
                switch post.imageStyle {
                    
                case 0:
                    imageStyle = CGSize(width: 400, height: 300)
                    break
                case 1:
                    imageStyle = CGSize(width: 300, height: 300)
                    break
                case 2:
                    imageStyle = CGSize(width: 400, height: 300)
                    break
                case 3:
                    imageStyle = CGSize(width: 300, height: 400)
                    break
                    
                default:
                    imageStyle = CGSize(width: 400, height: 300)
                }
                self.buildNode(latitude: post.latitude, longitude: post.longitude, altitude: post.altitude, imageURL: URL(string: post.editedImageUrl)!, size: imageStyle, pinUse: true, pinName: post.postId!, postId: post.postId!) { node in
                    nodes.append(node)
                    dispatchGroup.leave()
                }
            }
        })
        
        dispatchGroup.notify(queue: dispatchQueue) {
            completion(nodes)
        }
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
        
        
        buildPostData { [weak self] nodes in
            nodes.forEach {
                self?.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                
            }
        }
        sceneLocationView.autoenablesDefaultLighting = true
        
        
    }
    
    var annotationArray: [MKAnnotation] = []
    
    
    
    //MARK: - ここからオブジェクトを生成するためのやつだよ
    
    
    
    /// AR生成するためのfunc
    /// - Parameters:
    ///   - latitude: 座標1
    ///   - longitude: 座標2
    ///   - altitude: 高さ
    ///   - imageURL: ARに表示させる画像のURL
    ///   - size: 画像サイズ
    ///   - pinUse: ピン使いますか？
    ///   - pinName: ピンの表示名
    ///   - postId: 投稿ID
    ///   - completion: completion description
    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance,
                   imageURL: URL, size: CGSize,
                   pinUse: Bool, pinName: String,
                   postId: String,
                   completion: @escaping(LocationAnnotationNode) -> Void) {
        //座標
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //高さ込みの設置する座標
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        //地図に設置するピン
        let annotation = MKPointAnnotation()
        
        
        //初期画像
        var image:UIImage = UIImage(named: "ロゴ")!
        //URLから画像を取得してannotationNodeに入れる(非同期)
        AF.request(imageURL.absoluteString).responseImage { [weak self] res in
            switch res.result {
                //画像からURLが取得できた場合
            case .success(let getImage):
                print("IMAGE", getImage)
                //取得した画像をimageに入れる
                image = getImage.reSizeImage(reSize: size)
                
                //投稿IDを画像のタグに書き込む
                image.accessibilityIdentifier = postId
                print("---------------------------------------")
                print("accessibilityIdentifier: ",image.accessibilityIdentifier as Any)
                print("---------------------------------------")
                if pinUse {//地図にピンを表示する場合
                    //ピンの座標
                    annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    //ピンのタイトル
//                    annotation.title = pinName
                    //ピンのサブタイトル
                    annotation.subtitle = pinName
                    
                    //ピンをピンリストに追加
                    self?.annotationArray.append(annotation)
                    //マップにピンを表示
                    self?.mapView.addAnnotation(annotation)
                }
                
                //Nodeを生成
                let annotationNode = LocationAnnotationNode(location: location, image: image)
                completion(annotationNode)
                
            case .failure(let error):
                print("IMAGE", error)
                fatalError()
            }
        }
    }
    
    
    /// ARにテキストを表示せるよ
    /// - Parameters:
    ///   - latitude: 座標１
    ///   - longitude: 座標２
    ///   - altitude: 高さ
    ///   - text: テキスト
    ///   - color: 色
    /// - Returns: Nodeが帰っていきます
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
    
    
    /// ARにテキストを表示させるよ
    /// - Parameters:
    ///   - latitude: 座標１
    ///   - longitude: 座標２
    ///   - altitude: 高さ
    ///   - text: テキスト
    ///   - color: 色
    ///   - d3Object: d3Object description
    /// - Returns: description
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
    
    /// ごめんなさい使ってないけど今後に期待で残してるわからないやつです
    /// - Parameters:
    ///   - latitude: 座標１
    ///   - longitude: 座標２
    ///   - altitude: 高さ
    ///   - layer: layer description
    /// - Returns: description
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
            //            textLabel.text = "\(yDegrees)° • \(Float(heading).short)° • \(headingAccuracy)°\n \(locality ?? "")"
            textLabel.text = "\(locality ?? "")"
            //            textLabel.isHidden = true
        }
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
                withDuration: 0.2,
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
            withDuration: 0.2,
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
            Goto.ChatRoomView(view: self, image: URL(string: post.rawImageUrl)!, post: post)
        }
        
    }
    
    @IBAction func pushSelectCategory(_ sender: Any) {
        backTap()
        Goto.DebugView(view: self)
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
                Goto.ChatRoomView(view: self, image: URL(string: post.rawImageUrl)!, post: post)
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

extension ARViewController: MKMapViewDelegate {
    
    //MARK: ピンをタップしたときのイベント
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotations = view.annotation{
            print("subtitle: \(annotations.subtitle)")
            
            guard let unwrapSubTitle = annotations.subtitle,
                  let subtitle = unwrapSubTitle else {
                return
            }
            
            Firestore.firestore().collection("Posts").document(subtitle).getDocument {[weak self] (snapshot, err) in
                if let err = err {
                    print("投稿情報の取得に失敗しました。\(err)")
                    return
                }
                guard let dic = snapshot?.data() else { return }
                let post = Post(dic: dic, postId: subtitle)
                
                //TODO: 先に投稿画面に移行してその後非同期で画像を取得しよう
//                AF.request(post.rawImageUrl).responseImage { [weak self] res in
//                    switch res.result {
//                        //画像からURLが取得できた場合
//                    case .success(let downloadImage):
//                        Goto.ChatRoomView(view: self!, image: URL(string: post.rawImageUrl)!, post: post)
//
//                    case .failure(let error):
//                        print("IMAGE", error)
//                        fatalError()
//                    }
//                }
                Goto.ChatRoomView(view: self!, image: URL(string: post.rawImageUrl)!, post: post)
                
            }
            
            
        }
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
//
//        if annotation is MKUserLocation {
//            return nil
//        }
//
//        annotationView.displayPriority = .required
//        //        annotationView.glyphImage = UIImage(named: "katsu")! // SF Symbols の画像を使用
//        annotationView.glyphImage = nil
//        annotationView.image = UIImage(named: "katsu")!.reSizeImage(reSize: CGSize(width: 40, height: 40))
//        return annotationView
//    }
    
    
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
                mapView.userTrackingMode = .none
                flag.toggle()
                
            }
            
        }
    }
}
