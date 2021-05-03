//
//  RedditAPI.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import Foundation
import Moya

enum RedditAPI {
    case reddit(after: String)
}

extension RedditAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.reddit.com")!
    }

    var path: String {
        switch self {
        case .reddit: return "/.json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .reddit:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .reddit(after):
        return .requestParameters(parameters: ["after": after],
                                  encoding: URLEncoding.default)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
