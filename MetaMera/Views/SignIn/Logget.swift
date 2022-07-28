//
//  Logget.swift
//  MetaMera
//
//  Created by REO MASU on 2022/07/28.
//

import Foundation
import UIKit

class LogGet {
    
    
    func logPrint(uid:String, result: @escaping(Result<String, Error>) -> Void) {
        
        let url: URL = URL(string: "http://13.114.57.70:8000/metamera/?user_id=\(uid)")!
        let task: URLSessionTask = URLSession.shared.dataTask(
            with: url
        ) { (data, response, error) in
            
            if let error = error {
                print("error", error)
                result(.failure(error))
                return
            }
            // コンソールに出力
            print("test--")
            if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                if status == 200 {
                    print("success")
                    result(.success("success"))
                    return
                }else {
                    print("status error", status)
                    result(.failure(NSError(domain: "status error", code: status)))
                    return
                }
            }
            
        }
        task.resume()
        
    }
}

