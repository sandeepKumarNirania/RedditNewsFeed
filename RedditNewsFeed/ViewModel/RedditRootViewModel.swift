//
//  RedditRootViewModel.swift
//  RedditNewsFeed
//
//  Created by Sandeep Kumar on 03/05/21.
//

import Foundation
struct RedditRootViewModel {
    let created: String?
    let headerHash: String?
    let title: String?
    let imageURL: URL?
    let commentNumber: String?
    let score: Int?
    let after: String?
    private let thumbnailWidth: Double?
    private let thumbnailHeight: Double?

    var aspectRatio: Double {
        guard let width = thumbnailWidth,
              let height = thumbnailHeight else { return 1.0 }
        
        let _aspectRatio = (width < height)
                           ? (Double(width)/Double(height))
                           : (Double(height)/Double(width))
        return _aspectRatio
    }
    
    init(reddit: Reddit, afterCode: String?, header: String) {
        created = "\(reddit.child?.created ?? 0)"
        headerHash = header
        title = reddit.child?.title ?? ""
        commentNumber = "\(reddit.child?.numComments ?? 1)"
        score = reddit.child?.score
        after = afterCode
        let urlString = reddit.child?.thumbnail ?? ""
        imageURL = URL(string: urlString)
        thumbnailWidth = reddit.child?.thumbnailWidth
        thumbnailHeight = reddit.child?.thumbnailHeight
    }
}
