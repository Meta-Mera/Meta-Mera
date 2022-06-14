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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //少し縮小するアニメーション
//        UIView.animate(withDuration: 0.3,
//                                   delay: 1.0,
//                       options: UIView.AnimationOptions.curveEaseOut,
//                                   animations: { () in
//            self.logoImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        }, completion: { (Bool) in
//
//        })
        
//        UIView.animate(withDuration: 1.0, delay: 0.0, options: .autoreverse, animations: {
//            self.logoImageView.center.y -= 100.0
//        }, completion: nil)
        
        UIView.animate(withDuration: 1.0,
                       delay: 1.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { () in
            self.logoImageView.center.y -= 100.0
            
            
            
        }, completion: { (Bool) in
            self.logoImageView.removeFromSuperview()
            if let vc = UIStoryboard.instantiateInitialViewController(.init(name: "TopViewController", bundle: .main))() {
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: false)
            }
        })
        
        //拡大させて、消えるアニメーション
//        UIView.animate(withDuration: 0.2,
//                                   delay: 1.3,
//                       options: UIView.AnimationOptions.curveEaseOut,
//                                   animations: { () in
//            self.logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            self.logoImageView.alpha = 0
//        }, completion: { (Bool) in
//            self.logoImageView.removeFromSuperview()
//            let vc = TopViewController()
//            let navController = UINavigationController(rootViewController: vc)
//            navController.modalPresentationStyle = .fullScreen
//            self.present(navController, animated: true)
//
//        })
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
