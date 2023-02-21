//
//  ResetedPassViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2023/01/23.
//

import UIKit

class ResetedPassViewController: UIViewController {
    
    
    @IBOutlet weak var completeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func pushClose(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    

}
