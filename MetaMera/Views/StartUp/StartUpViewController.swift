//
//  StartUpViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/05/26.
//

import UIKit

class StartUpViewController: UIViewController {
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //ロゴを下から上に移動させるアニメーションです。
        UIView.animate(withDuration: 1.0,
                       delay: 1.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { () in
            self.logoImageView.center.y -= 100.0
            
            
        }, completion: { (Bool) in
            //アニメーションが終わったらTopViewControllerに移動します。
            self.logoImageView.removeFromSuperview()
            if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))() {
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: false)
            }
        })
        
    }
}
