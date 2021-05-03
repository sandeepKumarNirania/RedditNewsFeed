//
//  Network.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import Foundation
import Moya
import PromiseKit
import Alamofire

final class MoyaNetwork<Target: TargetType>: NetworkProvider {
    init() {}

    var provider = MoyaProvider<Target>()
    func request(_ target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?) -> Promise<Response> {
        return provider
            .request(target: target,
                     queue: callbackQueue,
                     progress: progress)
    }
}


protocol NetworkProvider: AnyObject {
    associatedtype Target: TargetType
    func request(_ target: Target, callbackQueue: DispatchQueue?, progress: Moya.ProgressBlock?) -> Promise<Response>
}

extension NetworkProvider {
    func request(_ target: Target) -> Promise<Response> {
        return request(target, callbackQueue: nil, progress: nil)
    }
}

import Foundation
import Moya
import PromiseKit

public typealias PendingRequestPromise = (promise: Promise<Moya.Response>, cancellable: Moya.Cancellable)
public extension MoyaProvider {
    func request(target: Target,
                 queue: DispatchQueue? = nil,
                 progress: Moya.ProgressBlock? = nil) -> Promise<Moya.Response>
    {
        return requestCancellable(target: target,
                                  queue: queue,
                                  progress: progress).promise
    }

    func requestCancellable(target: Target,
                            queue: DispatchQueue?,
                            progress: Moya.ProgressBlock? = nil) -> PendingRequestPromise
    {
        let pending = Promise<Moya.Response>.pending()
        let completion = promiseCompletion(fulfill: pending.resolver.fulfill,
                                           reject: pending.resolver.reject)
        let cancellable = request(target, callbackQueue: queue, progress: progress, completion: completion)
        return (pending.promise, cancellable)
    }

    private func promiseCompletion(fulfill: @escaping (Moya.Response) -> Void,
                                   reject: @escaping (Swift.Error) -> Void) -> Moya.Completion
    {
        return { result in
            switch result {
            case let .success(response):
                fulfill(response)
            case let .failure(error):
                reject(error)
            }
        }
    }
}

extension Promise where Promise.T == Moya.Response {
    func decode<U: Decodable>(decoder: JSONDecoder = JSONDecoder(),
                              as type: U.Type) -> Promise<U>
    {
        return map { (response) -> U in
            try decoder.decode(type, from: response.data)
        }
    }
    
    func decodeRedditResponse<U: Decodable>(decoder: JSONDecoder = JSONDecoder(),
                                          as type: U.Type) -> Promise<U>
    {
        return self.decode(as: RedditResponse<U>.self)
            .map { (RedditResponse) -> U in
                RedditResponse.data
            }
    }
}


public struct RedditResponse<T: Decodable>: Decodable {
    let kind: String?
    let data: T
}

