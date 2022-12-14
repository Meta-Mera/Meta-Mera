//
//  CreatePostViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit

class CreatePostViewController: UIViewController {

    @IBOutlet weak var createPostTableView: UITableView!
    
    private let mapCellId = "MapTableViewCell"
    private let photoCellId = "PhotoTableViewCell"
    
    private let tableViewContentInset : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private let tableViewIndicatorInser : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        // Do any additional setup after loading the view.
    }
    
    func configView() {
        createPostTableView.delegate = self
        createPostTableView.dataSource = self
        createPostTableView.register(UINib(nibName: "MapTableViewCell", bundle: nil) , forCellReuseIdentifier: mapCellId)
        createPostTableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil) , forCellReuseIdentifier: photoCellId)
        createPostTableView.rowHeight = UITableView.automaticDimension
        
        createPostTableView.contentInset = tableViewContentInset
        createPostTableView.scrollIndicatorInsets = tableViewIndicatorInser
        createPostTableView.keyboardDismissMode = .interactive
    }


}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource{
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            createPostTableView.estimatedRowHeight = 50
//            return UITableView.automaticDimension
//        }else{
//            createPostTableView.estimatedRowHeight = 20
//            return UITableView.automaticDimension
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath.section: ",indexPath.section)
        if indexPath.section == 0 {
            let cell = createPostTableView.dequeueReusableCell(withIdentifier: photoCellId, for: indexPath) as! PhotoTableViewCell
            
            return cell
        }else {
            let cell = createPostTableView.dequeueReusableCell(withIdentifier: mapCellId, for: indexPath) as! MapTableViewCell
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = .gray
            
            //            let titleLabel = UILabel()
            //            titleLabel.text = "header"
            //            titleLabel.frame = headerView.frame
            //            titleLabel.textColor = .white
            //
            //            headerView.addSubview(titleLabel)
            
            return headerView
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped table view")

    }
    
    
    
}
