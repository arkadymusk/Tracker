//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 27.01.2026.
//
import UIKit

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseId, for: indexPath)
        
        guard let cell = cell as? TrackerCell else {
            return cell
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        let cardColor = tracker.color

        let completed = isCompleted(trackerId: tracker.id)
        let count = completionsCount(trackerId: tracker.id)
        let canComplete = canCompleteSelectedDate()

        cell.configure(
            title: tracker.title,
            emoji: tracker.emoji,
            cardColor: cardColor,
            totalCompletions: count,
            isCompletedForSelectedDate: completed,
            canComplete: canComplete
        )

        cell.onToggle = { [weak self] in
            AnalyticsService.report(event: .click, screen: .main, item: .track)
            self?.toggleCompleted(trackerId: tracker.id)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeader.reuseId,
                for: indexPath
            )
            
            guard let header = header as? TrackerSectionHeader else {
                return header
            }
            
            header.titleLabel.text = visibleCategories[indexPath.section].header
            return header
        }

        return UICollectionReusableView()
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let inset: CGFloat = 16
            let spacing: CGFloat = 9
            let width = (collectionView.bounds.width - inset*2 - spacing) / 2
            return CGSize(width: floor(width), height: 148)
        }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 16 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let categoryTitle = visibleCategories[indexPath.section].header

        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }

            let editAction = UIAction(title: NSLocalizedString("trackers.editAction.title", comment: "")) { _ in
                AnalyticsService.report(event: .click, screen: .main, item: .edit)
                
                self.editTracker(tracker, categoryTitle: categoryTitle)
            }

            let deleteAction = UIAction(title: NSLocalizedString("trackers.deleteAction.title", comment: ""), attributes: .destructive) { _ in
                AnalyticsService.report(event: .click, screen: .main, item: .delete)
                
                self.deleteTracker(tracker)
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let identifier = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: identifier) as? TrackerCell
        else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: cell.contextMenuPreviewView.bounds,
            cornerRadius: 16
        )

        return UITargetedPreview(
            view: cell.contextMenuPreviewView,
            parameters: parameters
        )
    }
}

extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(_ vc: NewHabitViewController, didCreate tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, toCategory: categoryTitle)
        } catch {
            assertionFailure("Failed to save tracker: \(error)")
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStore(_ store: TrackerStore, didUpdate update: StoreUpdate) {
        categories = store.categories
    }
}

extension TrackersViewController: EditHabitViewControllerDelegate {
    func editHabitViewController(_ vc: EditHabitViewController,
                                 didUpdate tracker: Tracker,
                                 categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            assertionFailure("Failed to update tracker: \(error)")
        }
    }
}

final class TrackersViewController: UIViewController {
    private let trackerStore = TrackerStore()
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            updateVisibleCategories()
        }
    }
    private var visibleCategories: [TrackerCategory] = []
    private let completionStore = TrackerCompletionStore()
    let datePicker = UIDatePicker()
    private var selectedDate: Date = Date()
    
    private var selectedFilter: TrackersFilter = .all {
        didSet {
            updateVisibleCategories()
        }
    }

    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("trackers.filtres", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        return button
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .appBackground)

        navigationItem.title = NSLocalizedString("trackers.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapPlusButton)
        )
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 102),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("trackers.search.placeholder", comment: "")
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.searchTextField.backgroundColor = UIColor(resource: .appSearchBackground)
        searchController.searchBar.searchTextField.tintColor = UIColor(resource: .appSecondaryText)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        setupCollectionView()
        updatePlaceholder()
        setupPlaceholderImage()
        setupPlaceholderLabel()
        setupFilterButton()

        trackerStore.delegate = self
        categories = trackerStore.categories
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(event: .open, screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isBeingDismissed || self.isMovingFromParent {
            AnalyticsService.report(event: .close, screen: .main)
        }
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date

        if selectedFilter == .today {
            selectedFilter = .all
        }
        
        updateVisibleCategories()
        collectionView.reloadData()
    }
    
    private func editTracker(_ tracker: Tracker, categoryTitle: String) {
        let vc = EditHabitViewController(
            tracker: tracker,
            categoryTitle: categoryTitle,
            completedDaysCount: completionsCount(trackerId: tracker.id)
        )
        vc.delegate = self

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            assertionFailure("Failed to delete tracker: \(error)")
        }
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])

        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)

        collectionView.contentInset.bottom = 100
    }
    
    @objc
    private func didTapFilterButton() {
        AnalyticsService.report(event: .click, screen: .main, item: .filter)
        
        let vc = FiltersViewController(selectedFilter: selectedFilter)
        vc.onFilterSelected = { [weak self] filter in
            self?.applyFilter(filter)
        }

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func applyFilter(_ filter: TrackersFilter) {
        selectedFilter = filter

        if filter == .today {
            selectedDate = Date()
            datePicker.setDate(selectedDate, animated: true)
        }

        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {
        visibleCategories = makeVisibleCategories(from: categories)
        collectionView.reloadData()
        updatePlaceholder()
    }
    
    private func updatePlaceholder() {
        let hasAnyTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        let showPlaceholder = !hasAnyTrackers

        placeholderImage.isHidden = !showPlaceholder
        placeholderLabel.isHidden = !showPlaceholder
        collectionView?.isHidden = showPlaceholder
    }
    
    private func toggleCompleted(trackerId: UUID) {
        guard canCompleteSelectedDate() else { return }

        completionStore.toggleRecord(trackerId: trackerId, date: selectedDate)
        collectionView.reloadData()

        NotificationCenter.default.post(name: .statisticsDidChange, object: nil)
    }
    
    private func makeVisibleCategories(from categories: [TrackerCategory]) -> [TrackerCategory] {
        let day = selectedDate.weekday()

        return categories.compactMap { category in
            let filtered = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule.contains(day)

                guard matchesSchedule else { return false }

                switch selectedFilter {
                case .all, .today:
                    return true
                case .completed:
                    return completionStore.isCompleted(trackerId: tracker.id, date: selectedDate)
                case .uncompleted:
                    return !completionStore.isCompleted(trackerId: tracker.id, date: selectedDate)
                }
            }

            return filtered.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filtered)
        }
    }
    
    @objc
    private func didTapPlusButton() {
        AnalyticsService.report(event: .click, screen: .main, item: .addTrack)
        
        let createVC = NewHabitViewController()
        createVC.delegate = self

        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }
        
    private func isCompleted(trackerId: UUID) -> Bool {
        completionStore.isCompleted(trackerId: trackerId, date: selectedDate)
    }

    private func completionsCount(trackerId: UUID) -> Int {
        completionStore.completionsCount(for: trackerId)
    }

    private func canCompleteSelectedDate() -> Bool {
        let startOfSelected = Calendar.current.startOfDay(for: selectedDate)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return startOfSelected <= startOfToday
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(resource: .appBackground)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseId)
        collectionView.register(
            TrackerSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeader.reuseId
        )
    }
    
    private func setupPlaceholderImage() {
        view.addSubview(placeholderImage)
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderImage.image = UIImage(resource: .dizzy)
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    private func setupPlaceholderLabel() {
        view.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = NSLocalizedString("trackers.placeholder", comment: "")
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8)
        ])
    }
}
