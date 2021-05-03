//
//  RedditListViewController.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import UIKit

public protocol BaseView: NSObjectProtocol {}

enum ServiceState<T> {
    case loading
    case idle
    case success(_ viewModel: T)
    case failure(_ error: Error, retryHandler: (() -> Void))
}

open class CustomViewController: UIViewController {
    // MARK: - Methods

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("can't use it directly")
    }
}

/// Protocol that abstract the RedditListViewController
protocol RedditListView: BaseView {
}

final class RedditListViewController: CustomViewController, RedditListView {
    // MARK: - RedditListView

    /// A wrapper to the root view
    var rootView: RedditListRootView {
        return view as! RedditListRootView
    }

    var viewModel = RedditListViewModel()

    
    // MARK: - LifeCycle

    override init() {
        super.init()
    }

    override func loadView() {
        view = RedditListRootView()
        rootView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.fetchRedditList(code: "")
    }
}

// MARK: - RedditListOutputDelegate

extension RedditListViewController: RedditListOutputDelegate {
    func redditList(_: RedditListProtocol,
                    didUpdate state: RedditListState)
    {
        switch state {
        case .loading:
            rootView.showLoading()
        case .idle:
            break
        case let .success(viewModel):
            rootView.hideLoading()
            rootView.configure(with: viewModel)
        case let .failure(error, retry):
            rootView.hideLoading()
            rootView.showError(error: error.localizedDescription, retryClosure: retry)
        }
    }
}

// MARK: - RedditListRootViewDelegate

extension RedditListViewController: RedditListRootViewDelegate {
   
    func refreshData() {
        viewModel.refreshData()
    }
    
    func showAlert(alert: UIAlertController){
        present(alert, animated: true, completion: nil)
    }
    
    func rootViewNeedToFetchMore(code: String) {
        viewModel.fetchNewData(code: code)
    }

}

// MARK: - RedditListController Factory

/// RedditListController Factory
protocol RedditListControllerFactory {
    func makeRedditListController() -> RedditListView
}

extension RedditListControllerFactory {
    func makeRedditListController() -> RedditListView {
        return RedditListViewController()
    }
}
