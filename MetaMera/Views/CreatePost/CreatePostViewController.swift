//
//  CreatePostViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit

class CreatePostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configView() {
        tableView.delegate = self
        tableView.dataSource = self
    }


}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource{
    
    
}
