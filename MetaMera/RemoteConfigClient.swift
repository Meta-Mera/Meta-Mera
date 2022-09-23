//
//  RemoteConfigClient.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import Foundation
import Firebase

enum RemoteConfigParameterKey: String, CaseIterable {
    case serverMaintenance = "server_maintenance_config"
}


class RemoteConfigClient: RemoteConfigClientProtocol {
    
    static let shared = RemoteConfigClient()
    
    private var remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.fetchTimeout = 30
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
}
