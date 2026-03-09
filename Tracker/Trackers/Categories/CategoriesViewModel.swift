//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Аркадий Червонный on 09.03.2026.
//

import Foundation

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
}

final class CategoriesViewModel {
    private let store: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []
    private var selectedIndex: Int?

    var onDataChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onEmptyStateChanged: ((Bool) -> Void)?

    init(store: TrackerCategoryStore = TrackerCategoryStore(), selectedCategoryTitle: String? = nil) {
        self.store = store
        loadCategories()

        if let selectedCategoryTitle {
            selectedIndex = categories.firstIndex(where: { $0.header == selectedCategoryTitle })
        }
    }

    func loadCategories() {
        categories = store.fetchCategories()
        onDataChanged?()
        onEmptyStateChanged?(categories.isEmpty)
    }

    func numberOfRows() -> Int {
        categories.count
    }

    func cellViewModel(at index: Int) -> CategoryCellViewModel {
        let category = categories[index]
        return CategoryCellViewModel(
            title: category.header,
            isSelected: index == selectedIndex
        )
    }

    func selectCategory(at index: Int) {
        selectedIndex = index
        onDataChanged?()
        onCategorySelected?(categories[index].header)
    }

    func selectedCategoryTitle() -> String? {
        guard let selectedIndex else { return nil }
        return categories[selectedIndex].header
    }

    func createCategory(title: String) throws {
        try store.addCategory(title: title)
        loadCategories()

        if let index = categories.firstIndex(where: { $0.header == title }) {
            selectedIndex = index
        }
    }
}
