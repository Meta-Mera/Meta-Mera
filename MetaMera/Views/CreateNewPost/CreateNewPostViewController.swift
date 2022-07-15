//
//  CreateNewPostViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/07/15.
//

import Foundation
import UIKit

class CreateNewPostViewController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backView(_:))))
    }
    
    @objc func backView(_ sender: Any){
        print("push back image")
        self.dismiss(animated: true, completion: nil)
    }
    
}
