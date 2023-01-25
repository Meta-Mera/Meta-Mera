//
//  RemoteConfigClient.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

enum RemoteConfigParameterKey: String, CaseIterable {
    case serverMaintenance = "server_maintenance_config"
    case newRegistrationRestrictions = "new_registration_restrictions"
    case updateInfo = "updateInfo"
}


class RemoteConfigClient: RemoteConfigClientProtocol {
    
    static let shared = RemoteConfigClient()
    
    private var remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        
        #if RELEASE
        remoteConfig.fetch(withExpirationDuration: 0)
        #endif
        
//        settings.fetchTimeout = 30
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
    }
    
    func fetchServerMaintenanceConfig(succeeded: @escaping (ServerMaintenanceConfig) -> Void, failed: @escaping (String) -> Void) {
        remoteConfig.fetchAndActivate(completionHandler: { [weak self] status, error in
            
            guard let `self` = self else { return }
            
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                
                guard
                    let jsonString = self.remoteConfig[RemoteConfigParameterKey.serverMaintenance.rawValue].stringValue,
                    let jsonData = jsonString.data(using: .utf8) else {
                    return
                }
                
                do {
                    let config = try JSONDecoder().decode(ServerMaintenanceConfig.self, from: jsonData)
                    succeeded(config)
                } catch let error as NSError {
                    let errorMessage = error.localizedDescription
                    failed(errorMessage)
                }
                
            case .error:
                if let error = error {
                    let errorMessage = error.localizedDescription
                    failed(errorMessage)
                }
            default:
                return
            }
        })
    }
    
    func fetchRestrictionsConfig(succeeded: @escaping (newRegistrationRestrictionsConfig) -> Void, failed: @escaping (String) -> Void) {
        remoteConfig.fetchAndActivate(completionHandler: { [weak self] status, error in
            
            guard let `self` = self else { return }
            
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                
                guard
                    let jsonString = self.remoteConfig[RemoteConfigParameterKey.newRegistrationRestrictions.rawValue].stringValue,
                    let jsonData = jsonString.data(using: .utf8) else {
                    return
                }
                
                do {
                    let config = try JSONDecoder().decode(newRegistrationRestrictionsConfig.self, from: jsonData)
                    succeeded(config)
                } catch let error as NSError {
                    let errorMessage = error.localizedDescription
                    failed(errorMessage)
                }
                
            case .error:
                if let error = error {
                    let errorMessage = error.localizedDescription
                    failed(errorMessage)
                }
            default:
                return
            }
        })
    }
    
    func fetchUpdateInfoConfig(succeeded: @escaping (updateInfoConfig) -> Void, failed: @escaping (String) -> Void) {
        remoteConfig.fetchAndActivate(completionHandler: { [weak self] status, error in
            
            guard let `self` = self else { return }
            
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                
                guard
                    let jsonString = self.remoteConfig[RemoteConfigParameterKey.updateInfo.rawValue].stringValue,
                    let jsonData = jsonString.data(using: .utf8) else {
                    return
                }
                
                do {
                    let config = try JSONDecoder().decode(updateInfoConfig.self, from: jsonData)
                    succeeded(config)
                } catch let error as NSError {
                    let errorMessage = error.localizedDescription
                    failed(errorMessage)
                }
                
            case .error:
                if let error = error {
                    let errorMessage = error.localizedDescription
                    failed(errorMessage)
                }
            default:
                return
            }
        })
    }
}
