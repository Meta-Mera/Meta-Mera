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
import Nuke

extension LNTouchDelegate{
    func annotationNodeTouched(node: AnnotationNode) {
        if let nodeView = node.view{
            // Do stuffs with the nodeView
            // ...
            
            print("[nodeView]: ",nodeView)
        }
        if let nodeImage = node.image{
            // Do stuffs with the nodeImage
            // ...
            print("[nodeImage: getName]", nodeImage.accessibilityIdentifier ?? "null")
            
//            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let selectImage = nodeImage.accessibilityIdentifier else { return }
            
            //TODO: チャットルームを渡す方法を考える
            Firestore.firestore().collection("Posts").document(selectImage).getDocument { (snapshot, err) in
                if let err = err {
                    print("投稿情報の取得に失敗しました。\(err)")
                    return
                }
                
                guard let dic = snapshot?.data() else { return }
                let post = Post(dic: dic, postId: selectImage)
                Goto.ChatRoomView(view: self as! UIViewController, image: node.image!, post: post)
            }
//            Goto.ChatRoomView(view: self, image: node.image!, chatroomId: chatroom)
//            Goto.PostView(view: self, image: node.image!, chatroomId: selectImage)
        }
        
    }
    
    func locationNodeTouched(node: LocationNode) {
        guard let name = node.tag else { return }
        guard let selectedNode = node.childNodes.first(where: { $0.geometry is SCNBox }) else { return }
        
        print("name: "+name)
        print("selectedNode: ",selectedNode)
    }
}
