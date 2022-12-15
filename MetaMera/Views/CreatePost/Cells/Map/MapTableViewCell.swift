//
//  MapTableViewCell.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var postButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
