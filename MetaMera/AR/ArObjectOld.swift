//
//  ArObject.swift
//  MetaMera
//
//  Created by Jim on 2022/05/30.
//

import ARCL
import ARKit
import MapKit
import SceneKit

class ArObjectOld {
    
    var ar = ARViewController()
    
    func buildDemoData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []

        let canaryWharf = buildNode(latitude: 35.625318, longitude: 139.341903, altitude: 100, imageName: "pin")
        nodes.append(canaryWharf)

        let applePark = buildViewNode(latitude: 35.625835, longitude: 139.341659, altitude: 200, text: "広場")
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

        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            pikesPeakLayer.string = "Pike's Peak\n" + Date().description
        }

        let pikesPeak = buildLayerNode(latitude: 38.8405322, longitude: -105.0442048, altitude: 4705, layer: pikesPeakLayer)
        nodes.append(pikesPeak)

        return nodes
    }
    
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard ar.sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }
        
        buildDemoData().forEach {
            ar.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
            ar.sceneLocationView.moveSceneHeadingAntiClockwise()
        }

        // There are many different ways to add lighting to a scene, but even this mechanism (the absolute simplest)
        // keeps 3D objects fron looking flat
        ar.sceneLocationView.autoenablesDefaultLighting = true
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
                       altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = text
        label.backgroundColor = .green
        label.textAlignment = .center
        return LocationAnnotationNode(location: location, view: label)
    }

    func buildLayerNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                        altitude: CLLocationDistance, layer: CALayer) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        return LocationAnnotationNode(location: location, layer: layer)
    }
}
