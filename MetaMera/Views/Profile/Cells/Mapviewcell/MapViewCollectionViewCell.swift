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
    let accessory = Accessory()
    
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
                let pin = PostAnnotation.init()
                pin.post = post
                pin.postId = post.postId
                pin.coordinate = CLLocationCoordinate2DMake(post.latitude, post.longitude)
                self?.mapView.addAnnotation(pin)
                
            }
        })
        
    }
    
    @objc func tapButton(_ sender: UIButton){
        guard let postId = sender.accessibilityValue else {
            return
        }
        delegate?.pinTap(postId: postId)
    }
    
}

extension MapViewCollectionViewCell: MKMapViewDelegate{
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier:nil)
        
        if let annotation = annotation as? PostAnnotation{
            pinView.accessibilityValue = annotation.postId
            
            //吹き出しに表示するスタックビューを生成する。
            let stackView = UIStackView()
            stackView.axis = NSLayoutConstraint.Axis.vertical
            stackView.alignment = UIStackView.Alignment.leading
            
            
            //画像をスタックビューに追加する。
            let imageView = UIImageView()
            if let postImageURL = URL(string: annotation.post.rawImageUrl) {
                imageView.af.setImage(withURL: postImageURL)
            }
//            imageView.image?.reSizeImage(reSize: CGSize(width: 50, height: 50))
            stackView.addArrangedSubview(imageView)
            
            //スタックビューに投稿日時を追加する。
            let testLabel3:UILabel = UILabel()
            testLabel3.frame = CGRectMake(0,0,200,0)
            testLabel3.sizeToFit()
            testLabel3.text = accessory.dateFormatterForDateLabel(date: annotation.post.createdAt.dateValue())
            stackView.addArrangedSubview(testLabel3)
            
            //スタックビューにボタンを追加する。
            let button = UIButton()
            button.frame = CGRectMake(0,0,100,50)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle("開く", for: .normal)
            button.accessibilityValue = annotation.postId
            button.addTarget(self, action: #selector(tapButton(_:)), for: UIControl.Event.touchUpInside)
            stackView.addArrangedSubview(button)
            
//            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.70),
                stackView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.30)
            ])
            
            //ピンの吹き出しにスタックビューを設定する。
            pinView.detailCalloutAccessoryView = stackView
            
            //吹き出しの表示をONにする。
            pinView.canShowCallout = true
            
        }
        
        
        return pinView
    }
}
