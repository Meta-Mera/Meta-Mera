//
//  RemoteConfigClientProtocol.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import Foundation

protocol RemoteConfigClientProtocol {
    func fetchServerMaintenanceConfig(succeeded: @escaping (ServerMaintenanceConfig) -> Void, failed: @escaping (String) -> Void)
    func fetchRestrictionsConfig(succeeded: @escaping (newRegistrationRestrictionsConfig) -> Void, failed: @escaping (String) -> Void)
    func fetchUpdateInfoConfig(succeeded: @escaping (updateInfoConfig) -> Void, failed: @escaping (String) -> Void)
}
