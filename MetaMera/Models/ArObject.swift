//
//  ArObject.swift
//  MetaMera
//
//  Created by Jim on 2022/09/06.
//

import Foundation
import ARCL
import UIKit
import ARKit
import RealityKit
import MapKit
import SceneKit
import CoreLocation
import Firebase


class ArObject: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var annotationArray: [MKAnnotation] = []
    var sceneLocationView = SceneLocationView()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        sceneLocationView.showAxesNode = false
        sceneLocationView.locationNodeTouchDelegate = self
//        sceneLocationView.delegate = self // Causes an assertionFailure - use the `arViewDelegate` instead:
        sceneLocationView.arViewDelegate = self
        sceneLocationView.orientToTrueNorth = false
    }
    
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
    
    //MARK: ここで座標に基づいたオブジェクトを設置してるよ
    @objc func buildDemoData() -> [LocationAnnotationNode] {
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
    
    
    
    @objc func buildNodeData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        
        //35.75444876559928, 139.4811042224357
        
        let takaosan = buildNode(latitude: 35.75444876559928, longitude: 139.4811042224357, altitude: 100, imageName: "road",size: CGSize(width: 200, height: 300), pinUse: true, pinName: "road",postId: "test")
//        takaosan.scaleRelativeToDistance = true
        nodes.append(takaosan)

        return nodes
    }
}

extension ArObject: LNTouchDelegate{
    func annotationNodeTouched(node: AnnotationNode) {
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
                Goto.ChatRoomView(view: self as! UIViewController, image: node.image!, post: post)
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
