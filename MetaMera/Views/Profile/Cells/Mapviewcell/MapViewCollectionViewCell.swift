//
//  MapviewCollectionViewCell.swift
//  MetaMera
//
//  Created by 三橋史明 on 2022/11/04.
//

import UIKit
import MapKit
import Firebase

class MapViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: pinTapDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }
    
    private func configView(){
        mapView.delegate = self
    }
    
    func getUserPostData(){
        Firestore.firestore().collection("Posts").whereField("postUserUid", isEqualTo: Profile.shared.loginUser.uid).getDocuments(completion: {[weak self] (snapshot, error) in
            if let error = error {
                print("投稿データの取得に失敗しました。\(error)")
                return
            }
            
            for document in snapshot!.documents {
                let post = Post(dic: document.data(), postId: document.documentID)
                let pin = MKPointAnnotation()
                pin.subtitle = post.postId
                pin.accessibilityValue = post.postId
                pin.coordinate = CLLocationCoordinate2DMake(post.latitude, post.longitude)
                self?.mapView.addAnnotation(pin)
                
            }
        })

    }
    
    var row: Int?

    func setLessonData(row: Int) {
        // セルのインデックスを持たせておく
        self.row = row
    }

}

extension MapViewCollectionViewCell: MKMapViewDelegate{
    //MARK: ピンをタップしたときのイベント
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotations = view.annotation{

            guard let subtitle = annotations.subtitle! else {
                print("nil")
                return
            }

            delegate?.pinTap(postId: subtitle)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView

        if annotation is MKUserLocation {
            return nil
        }
        return annotationView
    }


}
