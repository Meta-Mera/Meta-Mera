//
//  CreatePostViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit

class CreatePostViewController: UIViewController {

    @IBOutlet weak var createPostTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private let mapCellId = "MapTableViewCell"
    private let photoCellId = "PhotoTableViewCell"
    
    private let tableViewContentInset : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private let tableViewIndicatorInser : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopLocation()
    }
    
    
    
    func configView() {

    }
    

    
    
    func setUpTableView(){
        createPostTableView.delegate = self
        createPostTableView.dataSource = self
        createPostTableView.register(UINib(nibName: "MapTableViewCell", bundle: nil) , forCellReuseIdentifier: mapCellId)
        createPostTableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil) , forCellReuseIdentifier: photoCellId)
        createPostTableView.rowHeight = UITableView.automaticDimension
        
        createPostTableView.contentInset = tableViewContentInset
        createPostTableView.scrollIndicatorInsets = tableViewIndicatorInser
        createPostTableView.keyboardDismissMode = .interactive
        createPostTableView.backgroundColor = .clear
        createPostTableView.allowsSelection = false
    }
    
    @IBAction func pushBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    


}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource{
//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            createPostTableView.estimatedRowHeight = 400
            return UITableView.automaticDimension
        }else{
            return UITableView.automaticDimension
        }
    }
    
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
            cell.backgroundColor = .clear
            
            cell.configView()
            
            return cell
        }else {
            let cell = createPostTableView.dequeueReusableCell(withIdentifier: mapCellId, for: indexPath) as! MapTableViewCell
            cell.backgroundColor = .clear
            
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
