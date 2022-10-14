//
//  DebugViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class DebugViewController: UIViewController {
    
    
    @IBOutlet weak var debugTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private let tableViewContentInset : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private let tableViewIndicatorInser : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private var safaAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    //    var postId: String!
    //    var post: Post!
    //    var user: User?
    
    var posts = [Post]()
    
    private let cellId = "PostTableViewCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        
    }
    
    func configView(){
        debugTableView.delegate = self
        debugTableView.dataSource = self
        debugTableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        debugTableView.rowHeight = UITableView.automaticDimension
        
        debugTableView.contentInset = tableViewContentInset
        debugTableView.scrollIndicatorInsets = tableViewIndicatorInser
        debugTableView.keyboardDismissMode = .interactive
    }
    
    //画面遷移しようとしたとき
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPostData()
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchPostData(){
        Firestore.firestore().collection("Posts").whereField("debug", isEqualTo: "true").getDocuments(){ [weak self] (postSnapshots, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            for document in postSnapshots!.documents {
                let post = Post(dic: document.data(), postId: document.documentID)
                self?.posts.append(post)
                self?.posts.sort { (m1, m2) -> Bool in
                    let m1Date = m1.createdAt.dateValue()
                    let m2Date = m2.createdAt.dateValue()
                    return m1Date < m2Date
                }
                print("投稿データの取得に成功しました。")
            }
            self?.debugTableView.reloadData()
        }
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    
}

extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
//        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = debugTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PostTableViewCell
        cell.post = posts[indexPath.row]
        cell.postDateLabel.text = dateFormatterForDateLabel(date: posts[indexPath.row].createdAt.dateValue())
        return cell
    }
    
    
}
