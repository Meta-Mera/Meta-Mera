//
//  LocationManager.swift
//  MetaMera
//
//  Created by Jim on 2022/10/14.
//

import Foundation
import UIKit
import CoreLocation
import ARCL

protocol locationAuthDelegate: AnyObject {
    func locationAuth()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var sceneLocationView: SceneLocationView?
    
    override init(){
        super.init()
        locationManager.delegate = self
    }
    
    func auth() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    var currentHeading: Double {
        return locationManager.heading?.trueHeading ?? 0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // デバイスの方位に合わせてSceneLocationViewを回転させる
        let camera = sceneLocationView?.scene.rootNode.childNode(withName: "camera", recursively: false)
        camera?.eulerAngles.y = Float(-1 * CGFloat(newHeading.trueHeading).toRadians())
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        adjustNorth(sceneLocationView: sceneLocationView!, userLocation: locationManager.location!)
//    }
//    
//    func adjustNorth(sceneLocationView: SceneLocationView, userLocation: CLLocation) {
//        let trueHeading = sceneLocationView.sceneLocationManager.currentHeading?.magneticHeading ?? 0
//        let location = CLLocation(coordinate: userLocation.coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
//        let north = -1 * Float(trueHeading).toRadians
//        sceneLocationView.locationEstimateMethod = .coreLocationData(location: location)
//        sceneLocationView.orientation = .custom(z: north, y: 0, x: 0)
//    }
}

//extension LocationManager: CLLocationManagerDelegate {

//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        let status = manager.authorizationStatus
//        print("location status", status)
//    }

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let coordinate = manager.location?.coordinate else {
//            return
//        }
//
////        print("lat", coordinate.latitude)
////        print("lon", coordinate.longitude)
//    }


//}
