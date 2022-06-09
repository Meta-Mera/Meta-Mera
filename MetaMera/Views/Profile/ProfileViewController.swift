//
//  ProfileViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/06/05.
//

import ARCL
import UIKit
import MapKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    
    let displayDebugging = true
    
    var ar = ARViewController()

    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?

    var updateUserLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?

    var centerMapOnUserLocation: Bool = true
    var routes: [MKRoute]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImage.layer.cornerRadius = 25
        changeProfileImageButton.layer.cornerRadius = 13
        
        MapView.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
    }
    
    //User Location
    let locationManager:CLLocationManager = CLLocationManager()
    
    var userLocation = MKUserLocation()
    
    override func viewWillAppear(_ animated: Bool) {
        MapView.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone
        locationManager.startUpdatingLocation()
        
        MapView.showsUserLocation = true
        
        // 縮尺を設定
        //var region:MKCoordinateRegion = MapView.region
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: MapView.userLocation.coordinate, span: span)
        

        MapView.setRegion(region,animated:true)
        
        
        //moveTo(center: MapView.userLocation, animated: true)
        
        
        
    }
    
    private func moveTo(
        center location: CLLocationCoordinate2D,
        animated: Bool,
        span: CLLocationDegrees = 0.01) {
        
        let coordinateSpan = MKCoordinateSpan(
            latitudeDelta: span,
            longitudeDelta: span
        )
        let coordinateRegion = MKCoordinateRegion(
            center: location,
            span: coordinateSpan
        )
        MapView.setRegion(
            coordinateRegion,
            animated: animated
        )
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func updateUserLocation() {
        guard let currentLocation = ar.sceneLocationView.sceneLocationManager.currentLocation else {
            return
        }

        DispatchQueue.main.async { [weak self ] in
            guard let self = self else {
                return
            }

            if self.userAnnotation == nil {
                self.userAnnotation = MKPointAnnotation()
                self.MapView.addAnnotation(self.userAnnotation!)
            }

            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.userAnnotation?.coordinate = currentLocation.coordinate
            }, completion: nil)

            if self.centerMapOnUserLocation {
                UIView.animate(withDuration: 0.45,
                               delay: 0,
                               options: .allowUserInteraction,
                               animations: {
                                self.MapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                }, completion: { _ in
                    self.MapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                })
            }

            if self.displayDebugging {
                if self.locationEstimateAnnotation != nil {
                    self.MapView.removeAnnotation(self.locationEstimateAnnotation!)
                    self.locationEstimateAnnotation = nil
                }
            }
        }
    }
    
    private func MAPLoad(){
        
    }
    
    
    @IBAction func pushChangeImage(_ sender: Any) {
        print("change image")
    }
    
}

extension ProfileViewController: MKMapViewDelegate{
    
}
