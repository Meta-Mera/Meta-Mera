//
//  WithdrawalViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit
import PKHUD
import Firebase

class WithdrawalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pushBackButon(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushNextButton(_ sender: Any) {
        let vc = CertificationViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func pushCancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
