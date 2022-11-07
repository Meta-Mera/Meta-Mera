//
//  MapviewCollectionViewCell.swift
//  MetaMera
//
//  Created by 三橋史明 on 2022/11/04.
//

import UIKit
import MapKit

class MapviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
