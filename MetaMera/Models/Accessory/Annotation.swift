//
//  Annotation.swift
//  MetaMera
//
//  Created by Jim on 2023/01/02.
//

import Foundation
import MapKit
import CoreLocation

class Annotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 35.748250, longitude: 139.480850)
    
    // Required if you set the annotation view's `canShowCallout` property to `true`
    var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
    
    // This property defined by `MKAnnotation` is not required.
    var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
}
