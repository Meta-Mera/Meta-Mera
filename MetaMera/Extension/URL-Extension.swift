//
//  URL-Extension.swift
//  MetaMera
//
//  Created by Jim on 2022/09/23.
//

import UIKit

extension URL {
    
    func asyncImage(completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: self) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}
