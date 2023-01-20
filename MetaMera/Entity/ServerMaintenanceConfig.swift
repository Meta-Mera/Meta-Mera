//
//  ServerMaintenanceConfig.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import Foundation

struct ServerMaintenanceConfig: Codable {
    let isUnderMaintenance: Bool
    let title: String
    let message: String
}

struct newRegistrationRestrictionsConfig: Codable {
    let newRegistrationRestrictions: Bool
    let limit: Int
}

