//
//  RedditListViewModel.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import Foundation
import PromiseKit

typealias RedditSection = SectionModel<String, RedditRootViewModel, Void>
typealias RedditListState = ServiceState<RedditListViewModel>

protocol RedditListProtocol {
    var delegate: RedditListOutputDelegate? { get set }
    var state: RedditListState { get }
    func refreshData()
    func fetchRedditList(code: String)
    func fetchNewData(code: String)
}

protocol RedditListOutputDelegate: AnyObject {
    /// Tells the delegate that the RedditListState state did update
    /// - Parameters:
    ///   - redditer: The redditer object informing the delegate of this impending event.
    ///   - state: The `RedditListState`  state
    func redditList(_ redditer: RedditListProtocol,
                    didUpdate state: RedditListState)
}

class RedditListViewModel: ViewModelSection {
    
    var currentPage: Int = 1
    weak var delegate: RedditListOutputDelegate?
    let provider = MoyaNetwork<RedditAPI>()
    var viewModel: RedditListViewModel?

    internal var isFetchInProgress = false
    var sections: [RedditSection] = []
    var code: String = ""

    /// The object describing the state of the RedditList API
    internal var state: RedditListState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?
                    .redditList(self, didUpdate: self.state)
            }
        }
    }
    
    init(){}

     init(redditResponseData: RootData?) {
        guard let _redditResponseData = redditResponseData else {
            return
        }
        guard let header = _redditResponseData.modhash,
              let rows = _redditResponseData.children?.compactMap({ (child) -> RedditRootViewModel in
            RedditRootViewModel(reddit: child,
                                afterCode: _redditResponseData.after, header: header)
        }) else {return}
        sections = [SectionModel(header: header, footer: nil, rows: rows)]
    }
}

extension RedditListViewModel: RedditListProtocol, LazyLoadingHandling {
     func refreshData() {
        fetchFromAPI()
    }
    
     func fetchRedditList(code: String){
        self.code = code
        self.fetchFirstPage(requestClosure: fetchFromAPI)
    }
    
     func fetchNewData(code: String) {
        self.code = code
        fetchFromAPI()
    }
    
     private func fetchFromAPI() {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        provider.request(.reddit(after: code)).decodeRedditResponse(as: RootData.self)
        .map{ rootData -> RedditListViewModel in
          return RedditListViewModel(redditResponseData: rootData)
        }
        .done(handleNewViewModel)
        .catch(policy: .allErrorsExceptCancellation) { [weak self] error in
            self?.isFetchInProgress = false
        }
    }
}


