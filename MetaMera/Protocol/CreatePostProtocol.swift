//
//  CreatePostProtocol.swift
//  MetaMera
//
//  Created by Jim on 2022/12/20.
//

import Foundation
import UIKit
import CoreLocation

protocol CreatePostDelegate {
    
    func postLocation(postLocation: CLLocationCoordinate2D, altitude: Double) -> Void
    
    func postPhoto(comment: String) -> Void
    
    func pushPhotoButton() -> Void
    
    func pushPostButton() -> Void
}

protocol photoUploadDelegate {
    func postImage(image: UIImage) -> Void
}
