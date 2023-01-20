//
//  PostInput.swift
//  MetaMera
//
//  Created by Jim on 2022/12/08.
//

import Foundation

enum PostInputError: Error {
    case emptyError
    case nilError
}

struct PostInput: PostGetterInput {
    typealias Payload = Self
    
    let postId: String?
    
    func validate() throws -> PostInput {
        guard let postId = postId else {
            throw PostInputError.nilError }
        if postId.isEmpty {
            throw PostInputError.emptyError
        }
        return self
    }
    
}
