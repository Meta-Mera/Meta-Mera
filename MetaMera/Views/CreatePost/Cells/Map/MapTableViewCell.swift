//
//  MapTableViewCell.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import Foundation
import UIKit
import Photos
import MapKit
import PKHUD
import Firebase

class MapTableViewCell: UITableViewCell, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var genreIdButton: UIButton!
    
    var selectedMenuType = GenreType.creator
    
    
    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        //creator
        actions.append(UIAction(title: LocalizeKey.creator.localizedString(), image: nil, state: self.selectedMenuType == GenreType.creator ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .creator
            self?.genreIdButton.setTitle(LocalizeKey.creator.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //design
        actions.append(UIAction(title: LocalizeKey.design.localizedString(), image: nil, state: self.selectedMenuType == GenreType.design ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .design
            self?.genreIdButton.setTitle(LocalizeKey.design.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //music
        actions.append(UIAction(title: LocalizeKey.music.localizedString(), image: nil, state: self.selectedMenuType == GenreType.music ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .music
            self?.genreIdButton.setTitle(LocalizeKey.music.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //IT
        actions.append(UIAction(title: LocalizeKey.It.localizedString(), image: nil, state: self.selectedMenuType == GenreType.It ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .It
            self?.genreIdButton.setTitle(LocalizeKey.It.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //technology
        actions.append(UIAction(title: LocalizeKey.technology.localizedString(), image: nil, state: self.selectedMenuType == GenreType.technology ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .technology
            self?.genreIdButton.setTitle(LocalizeKey.technology.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //sports
        actions.append(UIAction(title: LocalizeKey.sports.localizedString(), image: nil, state: self.selectedMenuType == GenreType.sports ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .sports
            self?.genreIdButton.setTitle(LocalizeKey.sports.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        
        // UIButtonにUIMenuを設定
        genreIdButton.menu = UIMenu(title: "Please select the name of the college", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        genreIdButton.showsMenuAsPrimaryAction = true
    }
    
    var locationManager = LocationManager()
    
    var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var userLocation = MKUserLocation()
    var altitude : Double = 0
    
    var pointAno: MKPointAnnotation = MKPointAnnotation()
    
    var delegate : CreatePostDelegate?
    
    private var isInitialMoveToMap: Bool = true
    private var isAnnotation: Bool = false
    
    private lazy var mapViewLongTapGuester: UILongPressGestureRecognizer = {
        let guester = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongTapped(_:)))
        return guester
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCircle(){
        configureMenuButton()
        locationManager.startLocation()
        mapView.layer.cornerRadius = 10
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.addGestureRecognizer(mapViewLongTapGuester)
        
        mapView.removeOverlays(mapView.overlays)
        
        var region = mapView.region
        region.center = CLLocationCoordinate2D(
            latitude: mapView.userLocation.coordinate.latitude,
            longitude: mapView.userLocation.coordinate.longitude)
        region.span.latitudeDelta = 0.008
        region.span.longitudeDelta = 0.008
        // マップビューに縮尺を設定
        mapView.setRegion(region, animated:true)
        
        //        mapView.setCenter(CLLocationCoordinate2D(
        //            latitude: mapView.userLocation.coordinate.latitude,
        //            longitude: mapView.userLocation.coordinate.longitude), animated:true)
        
        // 円を描画する(半径500m).
        let myCircle: MKCircle = MKCircle(
            center: CLLocationCoordinate2D(
                latitude: mapView.userLocation.coordinate.latitude,
                longitude: mapView.userLocation.coordinate.longitude),
            radius: CLLocationDistance(500)
        )
        //
        centerLocation = CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude,longitude: mapView.userLocation.coordinate.longitude)
        
        // mapViewにcircleを追加.
        mapView.addOverlay(myCircle)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func mapViewLongTapped(_ sender: UILongPressGestureRecognizer){
        
        //TODO:  長押しじゃなくて通常タップでピンを配置できるようにする
        
        let location:CGPoint = sender.location(in: mapView)
        //        isAnnotation = false
        if (sender.state == .began){
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        if (sender.state == .ended){
            //タップした位置を緯度、経度の座標に変換する。
            let mapPoint:CLLocationCoordinate2D = mapView.convert(location,toCoordinateFrom: mapView)
            
            // 半径のメートル指定
            let radius: CLLocationDistance = 500000
            let circularRegion = CLCircularRegion(center: centerLocation, radius: radius, identifier: "identifier")
            if circularRegion.contains(mapPoint) {
                mapView.removeAnnotation(pointAno)
                // 含まれる
                //ピンを作成してマップビューに登録する。
                pointAno.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
                pointAno.title = "投稿予定位置"
                pointAno.subtitle = "\(pointAno.coordinate.latitude), \(pointAno.coordinate.longitude)"
                mapView.addAnnotation(pointAno)
                
                isAnnotation = true
                delegate?.postLocation(postLocation: pointAno.coordinate, altitude: mapView.userLocation.location!.altitude, genreId: selectedMenuType.rawValue)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // rendererを生成.
        let myCircleView: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
        
        // 円の内部を赤色で塗りつぶす.
        //            myCircleView.fillColor = UIColor.red
        
        //        myCircleView.fill
        
        // 円周の線の色を設定.
        myCircleView.strokeColor = UIColor.brown
        
        // 円を透過させる.
        myCircleView.alpha = 0.5
        
        // 円周の線の太さ.
        myCircleView.lineWidth = 1.5
        
        return myCircleView
    }
    
    
    @IBAction func pushPostButton(_ sender: Any) {
        delegate?.pushPostButton()
    }
    
}
