//
//  ProfileSwipeViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/12/01.
//

import UIKit

class ProfileSwipeViewController: UIViewController {
    
    

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
        // Do any additional setup after loading the view.
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer) {

        switch sender.direction {
        case .left:
//            print("swiped left")
//            print("Goto-fixProfileViewController was called.")
            let vc = MetaMera.PhotoViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .right:
//            print("swiped right")
            break
        default:
            break
        }

    }

}
