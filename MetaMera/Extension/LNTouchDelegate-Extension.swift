//
//  LNTouchDelegate-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/09/06.
//

import ARCL
import UIKit
import ARKit
import RealityKit
import MapKit
import SceneKit
import CoreLocation
import FirebaseCore
import FirebaseStorage
import Firebase
import AudioToolbox

extension LNTouchDelegate{
    
    /// 画像をタップしたときに呼び出されます。
    /// - Parameter node: タップしたNode
    func annotationNodeTouched(node: AnnotationNode) {
        print("[tapEvent]: ", node.view?.tag as Any)
//        print("[findNodes]: ", sceneLocationView.findNodes(tagged: "drink"))
        if let nodeView = node.view{
            print("[nodeView]: ",nodeView)
        }
        if let nodeImage = node.image{ //タップしたNodeが画像なら

            print("[nodeImage: getName]", nodeImage.accessibilityIdentifier ?? "null")
            
            guard let selectImage = nodeImage.accessibilityIdentifier else { return }
            
            //TODO: チャットルームを渡す方法を考える
            Firestore.firestore().collection("Posts").document(selectImage).getDocument { (snapshot, err) in
                if let err = err {
                    print("投稿情報の取得に失敗しました。\(err)")
                    return
                }
                
                guard let dic = snapshot?.data() else { return }
                let post = Post(dic: dic, postId: selectImage)
//                Goto.ChatRoomView(view: self, image: node.image!, post: post)
            }
        }
        
    }
    
    func locationNodeTouched(node: LocationNode) {
        guard let name = node.tag else { return }
        guard let selectedNode = node.childNodes.first(where: { $0.geometry is SCNBox }) else { return }
        
        print("name: "+name)
        print("selectedNode: ",selectedNode)
    }
}
