//
//  APIResponseHandler.swift
//  Hyke
//
//  Created by Sandeep Kumar on  01/05/21.
//

import Foundation

protocol APIResponseHandler: class {
    associatedtype ViewModel

    var state: InteractorState<ViewModel> { get set }

    var viewModel: ViewModel? { get set }

    func success(with viewModel: ViewModel)

    func failure(_ error: Error)
}

extension APIResponseHandler {
    func success(with viewModel: ViewModel) {
        state = .success(viewModel)
        self.viewModel = viewModel
    }

    func failure(_ error: Error) {
        self.state = .failure(error, retryHandler: {})
    }

}

protocol LazyLoadingHandling: AnyObject {
    associatedtype ViewModel
    var state: InteractorState<ViewModel> { get set }
    var viewModel: ViewModel? { get set }
    var isFetchInProgress: Bool { get set }
    var currentPage: Int { get set }
}

extension LazyLoadingHandling where Self.ViewModel: ViewModelSection {
   
    func fetchFirstPage(requestClosure: () -> Void) {
        isFetchInProgress = false
        state = .loading
        currentPage = 1
        requestClosure()
    }

    func handleNewViewModel(_ viewModel: ViewModel) {
        if currentPage > 1, self.viewModel != nil {
            self.viewModel?.updateVM(with: viewModel)
        } else {
            self.viewModel = viewModel
        }
        currentPage += 1
        isFetchInProgress = false
        if let safeViewModel = self.viewModel {
            state = .success(safeViewModel)
        }
    }
}
