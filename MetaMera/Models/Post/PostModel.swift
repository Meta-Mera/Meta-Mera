//
//  PostModel.swift
//  MetaMera
//
//  Created by Jim on 2022/12/08.
//

import Foundation
import Firebase


final class PostGetter<API: PostGetterProtocol, Input: PostGetterInput> where API.Payload == Input.Payload {
    
    private let api: API
    private var input: Input {
        didSet {
            print("post getter input:", input)
        }
    }
    
    init(api: API, input: Input) {
        self.api = api
        self.input = input
    }
    
    func fetchData(completion: @escaping(API.Response) -> Void) {
        do {
            let payload = try input.validate()
            api.fetchPostData(payload: payload) { response in
                completion(response)
            }
        }catch {
//            completion.()
        }
    }
    
}

// MARK: FetchAPI
enum PostFetchResponse {
    case success(Post)
    case failure(Error)
}

final class PostFetchAPI: PostGetterProtocol {
    typealias Payload = PostInput
    typealias Response = PostFetchResponse

    func fetchPostData(payload: PostInput, completion: @escaping (PostFetchResponse) -> Void) {
        
        FirebaseManager.post.document(id: payload.postId!)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let doc = snapshot,
                      let dic = doc.data() else {
                    return
                }
                let post = Post(dic: dic, postId: doc.documentID)
                completion(.success(post))
            }
    }
    
    
}
