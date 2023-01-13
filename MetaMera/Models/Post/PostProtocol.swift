//
//  PostProtocol.swift
//  MetaMera
//
//  Created by Jim on 2022/12/08.
//

import Foundation

protocol PostGetterProtocol {
    associatedtype Payload
    associatedtype Response
    func fetchPostData(payload: Payload, completion: @escaping(Response) -> Void)
}

protocol PostGetterInput {
    associatedtype Payload
    func validate() throws -> Payload
}
