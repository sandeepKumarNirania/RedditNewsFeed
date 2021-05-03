
//  SectionModel.swift
//  Reddit NewsFeed
//
//  Created by Sandeep Kumar on  01/05/21.
//

import Foundation

protocol SectionType {
    associatedtype Header
    associatedtype Row
    associatedtype Footer

    var header: Header? { get }
    var footer: Footer? { get }
    var rows: [Row] { get }
    var totalRows: Int { get }
    var moreDataAvailable: Bool { get }

}

public struct SectionModel<Header, Row, Footer>: SectionType {
    public var header: Header?
    public var footer: Footer?
    public var rows: [Row]

    var totalRows: Int {
        if !rows.isEmpty {
            if !moreDataAvailable {
                return rows.count
            } else {
                return rows.count + 1
            }
        } else {
            return rows.count
        }
    }

    private var newRows: [Row] = []

    internal var moreDataAvailable: Bool = true

    public init(header: Header? = nil,
                footer: Footer? = nil,
                rows: [Row])
    {
        self.header = header
        self.footer = footer
        self.rows = rows
    }
    
    mutating func addRows(newRows: [Row]) {
        self.moreDataAvailable = !newRows.isEmpty
        self.rows.append(contentsOf: newRows)
    }

    private func calculateIndexRowsToReload(from newItems: [Row]) -> [Int] {
        let startIndex = self.rows.count - newItems.count
        let endIndex = startIndex + newItems.count
        return (startIndex ..< endIndex).map { $0 }
    }

    internal func isLoadingRow(for indexPath: IndexPath) -> Bool {
        return self.moreDataAvailable
    }
}

extension Array where Element: SectionType {

    func contains(indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return self.indices.contains(section) && self[section].rows.indices.contains(row)
    }

    func header(at section: Int) -> Element.Header? {
        guard indices.contains(section) else {
            return nil
        }
        return self[section].header
    }

    func row(at indexPath: IndexPath) -> Element.Row? {
        guard self.contains(indexPath: indexPath) else {
            return nil
        }
        return self[indexPath.section]
            .rows[indexPath.row]
    }

    func isLoadingRow(for indexPath: IndexPath) -> Bool {
        guard indexPath.section >= 0, indexPath.section < self.count else {
            return false
        }
        let section = indexPath.section
        return self[section].moreDataAvailable
    }
}

protocol ViewModelSection {
    associatedtype Header: Equatable
    associatedtype Row
    associatedtype Footer
    typealias Section = SectionModel<Header, Row, Footer>
    var sections: [Section] { get set }
}

extension ViewModelSection {
    mutating func updateVM(with viewModel: Self) {
        guard !viewModel.sections.isEmpty, !self.sections.isEmpty else {
            self.sections.indices.forEach { index in
                self.sections[index].moreDataAvailable = false
            }
            return
        }
        for value in viewModel.sections {
            if value.header != nil {
                let newerSection = value
                let matchedSection = self.sections.first { (section) -> Bool in
                    section.header == newerSection.header
                }
                    self.sections.append(value)
                    var lastSection = self.sections[self.sections.count - 1]
                    lastSection.addRows(newRows: [])
            }
        }
    }
}
