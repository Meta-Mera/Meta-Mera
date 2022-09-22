//
//  DebugViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import Foundation
import UIKit

class DebugViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    
    var postId: String!
    var post: Post!
    var user: User?
    
    private let cellId = "PostTableViewCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
