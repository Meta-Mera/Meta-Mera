//
//  PhotoViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/12/01.
//

import UIKit

class PhotoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //右へ
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        //左へ
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        
        rightSwipeGesture.direction = .right
        leftSwipeGesture.direction = .left
        
        view.addGestureRecognizer(rightSwipeGesture)
        view.addGestureRecognizer(leftSwipeGesture)
        
    }
    
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .left:
            //            print("swiped left")
            break
        case .right:
            //            print("swiped right")")
            let vc = MetaMera.ProfileSwipeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
        
    }
    
}
