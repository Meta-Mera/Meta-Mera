//
//  MapKitManager.swift
//  MetaMera
//
//  Created by Jim on 2022/12/20.
//

import Foundation
import MapKit


class MapKitManager: NSObject {
    
    
}

extension MapKitManager: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            // rendererを生成.
            let myCircleView: MKCircleRenderer = MKCircleRenderer(overlay: overlay)

            // 円の内部を赤色で塗りつぶす.
            myCircleView.fillColor = UIColor.red

            // 円周の線の色を黒色に設定.
            myCircleView.strokeColor = UIColor.black

            // 円を透過させる.
            myCircleView.alpha = 0.5

            // 円周の線の太さ.
            myCircleView.lineWidth = 1.5

            return myCircleView
        }
}
