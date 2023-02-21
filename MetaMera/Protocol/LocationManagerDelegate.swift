//
//  LocationManagerDelegate.swift
//  MetaMera
//
//  Created by Jim on 2023/02/18.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) -> Void
}
