//
//  RedditListRootView.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import UIKit

protocol RedditListRootViewDelegate: AnyObject {
    func refreshData()
    func showAlert(alert: UIAlertController)
    func rootViewNeedToFetchMore(code: String)
}

final class RedditListRootView: UIView {
    unowned var delegate: RedditListRootViewDelegate?

    var viewModel = RedditListViewModel(redditResponseData: nil)

    let activityIndicator = UIActivityIndicatorView(style: .medium)

    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RedditCell.self, forCellReuseIdentifier: "RedditCell")
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(needToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        backgroundColor = .white
        activityIndicator.hidesWhenStopped = true
        addSubview(tableView) {
            $0.edges.pinToSuperview()
        }

        addSubview(activityIndicator) {
            $0.center.alignWithSuperview()
        }
    }

    @objc func needToRefresh() {
        tableView.refreshControl?.endRefreshing()

        delegate?.refreshData()
    }

    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func showError(error: String, retryClosure: @escaping (() -> Void)) {
        let showCancelButton = !(viewModel.sections.first?.rows.isEmpty ?? true)
        
        let alert = UIAlertController(title: "", message: error, preferredStyle: .alert)
               let ok = UIAlertAction(title: "Retry", style: .default, handler: { (action) -> Void in
                   retryClosure()
               })
               let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
               }
        alert.addAction(ok)
        if(showCancelButton){
          alert.addAction(cancel)
        }
        delegate?.showAlert(alert: alert)
    }
}

// MARK: - ViewConfigurable

extension RedditListRootView {
    func configure(with viewModel: RedditListViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
    }
}

extension RedditListRootView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !viewModel.sections.isEmpty else { return 0 }
        if section == viewModel.sections.count - 1 {
            return viewModel.sections[section].totalRows
        } else {
            return viewModel.sections[section].rows.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let emptyCell = UITableViewCell()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RedditCell", for: indexPath) as? RedditCell else {  return emptyCell }
        if let rowViewModel = viewModel.sections.row(at: indexPath) {
            cell.configure(with: rowViewModel)
        } else {
            return emptyCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         if indexPath.section == viewModel.sections.count - 1,
            indexPath.row == 0,
            viewModel.sections.isLoadingRow(for: indexPath),
            let rowViewModel = viewModel.sections.row(at: indexPath),
                let nextAfterCode = rowViewModel.after {
                print("\n ==>>>>>>>>> indexPath is \(indexPath)  \n ==>>>>>>>>> nextAfterCode is \(nextAfterCode) \n ==>>>>>>>>> header is \(rowViewModel.headerHash!)")
                delegate?.rootViewNeedToFetchMore(code: nextAfterCode)
            }
    }
}
