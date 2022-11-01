//
//  Report.swift
//  MetaMera
//
//  Created by Jim on 2022/10/24.
//

import Foundation
import Firebase
import UIKit

class Report {

    let reportId: String
    
    init(dic: [String: Any], documentId: String) {
        self.reportId = documentId
    }
}

class ReportUsers {
    
    let uid: String
    let reportGenreId: String
    let reportComment: String
    let createdAt: Timestamp
    let postId: String
    
    init(dic: [String: Any], uid: String) {
        self.uid = uid
        self.postId = dic["postId"] as? String ?? ""
        self.reportGenreId = dic["reportGenreId"] as? String ?? ""
        self.reportComment = dic["reportComment"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
