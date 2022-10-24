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
    let reportCount: Int
    let createdAt: Timestamp
    
    init(dic: [String: Any], documentId: String) {
        self.reportId = documentId
        self.reportCount = dic["reportCount"] as? Int ?? 1
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}

class ReportUsers {
    
    let uid: String
    let reportGenreId: Int
    let reportComment: String
    let createdAt: Timestamp
    
    init(dic: [String: Any], uid: String) {
        self.uid = uid
        self.reportGenreId = dic["reportGenreId"] as? Int ?? 1
        self.reportComment = dic["reportComment"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
