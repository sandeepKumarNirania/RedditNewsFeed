//
//  RedditListInteractor.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import Foundation
import PromiseKit

typealias RedditListState = InteractorState<RedditListViewModel>

protocol RedditListInteractorInput {
    var delegate: RedditListInteractorDelegate? { get set }

    var viewModel: RedditListViewModel? { get }

    var state: RedditListState { get }
    
    func refreshData()
    func fetchRedditList(code: String)
    func fetchNewData(code: String)
}

protocol RedditListInteractorDelegate: AnyObject {
    /// Tells the delegate that the interactor state did update
    ///
    /// - Parameters:
    ///   - interactor: The interactor object informing the delegate of this impending event.
    ///   - state: The `interactor`  state
    func interactor(_ interactor: RedditListInteractorInput,
                    didUpdate state: RedditListState)
}

final class RedditListInteractor: RedditListInteractorInput, APIResponseHandler, LazyLoadingHandling {
    
    var currentPage: Int = 1
    
    weak var delegate: RedditListInteractorDelegate?

    let provider = MoyaNetwork<RedditAPI>()

    internal var viewModel: RedditListViewModel?

    internal var isFetchInProgress = false

    var code: String = ""

    /// The object describing the state of the Interactor
    internal var state: RedditListState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?
                    .interactor(self, didUpdate: self.state)
            }
        }
    }

    init() {}
    

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
            self?.failure(error)
        }
    }
}

protocol RedditListInteractorFactory {
    func makeRedditListInteractor() -> RedditListInteractorInput
}
