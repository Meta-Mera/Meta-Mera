//
//  ViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/10.
//


import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //Tap関連
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var SubLabel: UILabel!
    @IBOutlet weak var HideButton: UIButton!
    @IBOutlet weak var ShowButton: UIButton!
    @IBOutlet weak var arView: ARView!
    
    
    //GPS関連
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Label.text = "Event: Null"
        SubLabel.text = "Location: Null"
        
        /**arView.debugOptions.insert(.showSceneUnderstanding)
        
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification

        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)*/
        
        
        //タップ
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapRecognizer)
        
        //長押し
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        arView.addGestureRecognizer(longPressGesture)
        
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        rightSwipeGesture.direction = .right
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        leftSwipeGesture.direction = .left
        //上へ
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        upSwipeGesture.direction = .up
        //下へ
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        downSwipeGesture.direction = .down
        
        arView.addGestureRecognizer(rightSwipeGesture)
        arView.addGestureRecognizer(leftSwipeGesture)
        arView.addGestureRecognizer(upSwipeGesture)
        arView.addGestureRecognizer(downSwipeGesture)
        
        //GPS関連
        locationManager = CLLocationManager()
    
        //locationManager!.delegate = self
        
        //locationManager?.requestLocation()
        //locationManager?.requestWhenInUseAuthorization()
        
        locationManager!.requestAlwaysAuthorization()
        locationManager!.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.startUpdatingLocation()
            
        }
        
        /*//位置情報を使用可能か
            if CLLocationManager.locationServicesEnabled() {
            //位置情報の取得開始
            locationManager!.startUpdatingLocation()
        }
        
        // 常に使用する場合、バックグラウンドでも取得するようにする
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
             // バックグラウンドでも取得する
             locationManager!.allowsBackgroundLocationUpdates = true
        } else {
             // バックグラウンドでは取得しない
             locationManager!.allowsBackgroundLocationUpdates = false
        }

        // 位置情報の取得精度を指定します
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest

        // 更新に必要な最小移動距離
        // Int値を指定することで、○○m間隔で取得するようになります
        locationManager!.distanceFilter = 10

        // 移動手段を指定します
        // 徒歩、自動車等
        locationManager!.activityType = .fitness

        // 位置情報取得開始
        locationManager!.startUpdatingHeading()*/
        
        
        //3Dモデルの表示
        // Load the "Box" scene from the "Experience" Reality File
        //let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        
        
        //arView.session.run(ARGeoTrackingConfiguration())
        //arView.scene.anchors.append(boxAnchor)
        
        let sun = SCNNode(geometry: SCNSphere(radius: 0.20))

        // 表示位置を指定
        sun.position = SCNVector3(0, 0, -1)

        // ARSCNViewに作成物を追加
        
        
        
        Label.font = UIFont(name: "utakata", size: 20)
        
    }
    
    @IBAction func PushShowButton(_ sender: Any) {
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.reloadInputViews()
        
        let vc = TopViewController()
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    @IBAction func PushHideButton(_ sender: Any) {
        arView.debugOptions.remove(.showSceneUnderstanding)
        let vc = ARViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
        Label.text = "Event: tapped"
    }

    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began {
            //長押し開始
            print("began press")
            Label.text = "Event: began press"
        } else if sender.state == .ended {
            //長押し終了
            print("ended press")
            Label.text = "Event: ended press"
        }

    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {

        switch sender.direction {
        case .left:
            print("swiped left")
            Label.text = "Event: swiped left"
        case .right:
            print("swiped right")
            Label.text = "Event: swiped right"
        case .up:
            print("swiped up")
            Label.text = "Event: swiped up"
        case .down:
            print("swiped down")
            Label.text = "Event: swiped down"
        default:
            break
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        SubLabel.text = "Location:\n \(locValue.latitude) \n \(locValue.longitude)"
    }
}
