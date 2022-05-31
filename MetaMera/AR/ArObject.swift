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
import UIKit

class ArObject {
    
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
