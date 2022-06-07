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


class ARViewController: UIViewController, UITextFieldDelegate, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    //    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var textLabel: UILabel!
    
    var updateInfoLabelTimer: Timer?
    
    var sceneLocationView = SceneLocationView()
    var locationManager = CLLocationManager()
    
    private lazy var chatView: ChatViewController = {
        let view = ChatViewController()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load the "Box" scene from the "Experience" Reality File
        
        do {
            let boxAnchor = try Experience.loadBox()
            //arView.scene.anchors.append(boxAnchor)
            //sceneLocationView
        }catch {
            print("error")
        }
        
        //MARK: 位置情報のやつっぽい
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()

        locationManager.requestWhenInUseAuthorization()
        
        // MARK: ここからARのやつのやつ
        
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
        
        
        
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationNodeTouchDelegate = self
//        sceneLocationView.delegate = self // Causes an assertionFailure - use the `arViewDelegate` instead:
        sceneLocationView.arViewDelegate = self
        sceneLocationView.locationNodeTouchDelegate = self
        
        
        addSceneModels()
        
        
//        sceneLocationView.run()
        contentView.addSubview(sceneLocationView)
        
        sceneLocationView.frame = .zero
        
//        sceneLocationView.run()
        
        // Do any additional setup after loading the view.
        
        updateInfoLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateInfoLabel()
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneLocationView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAnimation()
    }
    
    
    // MARK: ここからAR
    
    func pauseAnimation() {
        print("pause")
        sceneLocationView.pause()
    }

    func restartAnimation() {
        sceneLocationView.isPlaying = true
        DispatchQueue.main.async { [weak self] in
            
            print("run")
            self?.sceneLocationView.run()
        }
        
    }
    
    func buildDemoData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []

//        let canaryWharf = buildNode(latitude: 35.625318, longitude: 139.341903, altitude: 100, imageName: "pin")
//        nodes.append(canaryWharf)

        let applePark = buildViewNode(latitude: 35.625835, longitude: 139.341659, altitude: 200, text: "広場", color: UIColor.red)
        nodes.append(applePark)

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
        
        let applePark1 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 200, text: "200", color: UIColor.green)
        nodes.append(applePark1)
        let applePark2 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 210, text: "210", color: UIColor.green)
        nodes.append(applePark2)
        let applePark3 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 230, text: "230", color: UIColor.green)
        nodes.append(applePark3)
        let applePark4 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 280, text: "280", color: UIColor.green)
        nodes.append(applePark4)
        let applePark5 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 290, text: "290", color: UIColor.green)
        nodes.append(applePark5)
        let applePark6 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 310, text: "310", color: UIColor.green)
        nodes.append(applePark6)
        let applePark7 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 320, text: "320", color: UIColor.green)
        nodes.append(applePark7)
        
        let applePark8 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 190, text: "190", color: UIColor.green)
        nodes.append(applePark8)
        let applePark9 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 180, text: "180", color: UIColor.green)
        nodes.append(applePark9)
        let applePark10 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 170, text: "170", color: UIColor.green)
        nodes.append(applePark10)
        let applePark11 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 160, text: "160", color: UIColor.green)
        nodes.append(applePark11)
        let applePark12 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 150, text: "150", color: UIColor.green)
        nodes.append(applePark12)
        let applePark13 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 140, text: "140", color: UIColor.green)
        nodes.append(applePark13)
        let applePark14 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 130, text: "130", color: UIColor.green)
        nodes.append(applePark14)
        let applePark15 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 120, text: "120", color: UIColor.green)
        nodes.append(applePark15)
        let applePark16 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 110, text: "110", color: UIColor.green)
        nodes.append(applePark16)
        let applePark17 = buildViewNode(latitude: 35.624929, longitude: 139.341696, altitude: 100, text: "100", color: UIColor.green)
        nodes.append(applePark17)
        

        return nodes
    }
    
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
        }
        
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        cubeNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
        
        sceneLocationView.scene.rootNode.addChildNode(cubeNode)

        // There are many different ways to add lighting to a scene, but even this mechanism (the absolute simplest)
        // keeps 3D objects fron looking flat
        sceneLocationView.autoenablesDefaultLighting = true
        //sceneLocationView.useTrueNorth = false
        

    }

    
    
    
    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let image = UIImage(named: imageName)!
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
            textLabel.text = " Heading: \(yDegrees)° • \(Float(heading).short)° • \(headingAccuracy)°\n"
        }
    }
    
    // MARK: 位置情報のやつ
    
    
    
}

extension ARViewController: ChatViewControllerDelegate{
    func tappedSendButton(text: String) {
        print(text)
    }
}

extension ARViewController: LNTouchDelegate {
    func annotationNodeTouched(node: AnnotationNode) {
        
    }
    
    func locationNodeTouched(node: LocationNode) {
        
    }
    

}
