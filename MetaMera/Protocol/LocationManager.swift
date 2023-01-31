//
//  LocationManager.swift
//  MetaMera
//
//  Created by Jim on 2022/10/14.
//

import Foundation
import UIKit
import CoreLocation

protocol locationAuthDelegate: AnyObject {
    func locationAuth()
}

class LocationManager: NSObject {
    
    let locationManager = CLLocationManager()
    
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
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation(){
        locationManager.stopUpdatingLocation()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("location status", status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = manager.location?.coordinate else {
            return
        }
        
//        print("lat", coordinate.latitude)
//        print("lon", coordinate.longitude)
    }
}
