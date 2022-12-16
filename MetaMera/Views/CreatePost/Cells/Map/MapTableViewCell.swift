//
//  MapTableViewCell.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit
import MapKit
import CoreLocation

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var postButton: UIButton!
    
    var locationManager = LocationManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCircle(){
        locationManager.startLocation()
        mapView.showsUserLocation = true
        
        // 円を描画する(半径500m).
        let myCircle: MKCircle = MKCircle(center: CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude,longitude: mapView.userLocation.coordinate.longitude), radius: CLLocationDistance(500))
//
//        center = CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude,longitude: mapView.userLocation.coordinate.longitude)
        
        // mapViewにcircleを追加.
        mapView.addOverlay(myCircle)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
