//
//  AreaIdModel.swift
//  MetaMera
//
//  Created by Jim on 2022/10/14.
//

import Foundation

class AreaId {
    
    let areaId: String
    let areaName: String
    
    init(dic: [String: Any]) {
        self.areaId = dic["areaId"] as? String ?? ""
        self.areaName = dic["areaName"] as? String ?? ""
    }
    
    
}
