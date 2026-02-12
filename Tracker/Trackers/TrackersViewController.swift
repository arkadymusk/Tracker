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
}

extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(_ vc: NewHabitViewController, didCreate tracker: Tracker, categoryTitle: String) {
        addTracker(tracker, to: categoryTitle)
    }
}

final class TrackersViewController: UIViewController {
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            updateVisibleCategories()
        }
    }
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    let datePicker = UIDatePicker()
    private var selectedDate: Date = Date()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = "Трекеры"
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
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        setupCollectionView()
        updatePlaceholder()
        setupPlaceholderImage()
        setupPlaceholderLabel()
        
        
        categories = [
            TrackerCategory(header: "Дом", trackers: [
                Tracker(id: UUID(), title: "Полить цветы", color: .ypBlue, emoji: "🌿", schedule: [.monday, .wednesday]),
                Tracker(id: UUID(), title: "пропылесосить", color: .black, emoji: "🌿", schedule: [.monday, .wednesday])
            ]),
            TrackerCategory(header: "Учеба", trackers: [
                Tracker(id: UUID(), title: "Homework", color: .ypLightGray, emoji: ")", schedule: [.monday, .wednesday])
            ])
        ]
        updatePlaceholder()
        collectionView.reloadData()
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        updateVisibleCategories()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        collectionView.reloadData()
    }
    
    private func updateVisibleCategories() {
        let day = selectedDate.weekday()

        visibleCategories = categories.compactMap { category in
            let filtered = category.trackers.filter { tracker in
                tracker.schedule.contains(day)
            }
            return filtered.isEmpty ? nil : TrackerCategory(header: category.header, trackers: filtered)
        }

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

        if let index = completedTrackers.firstIndex(where: {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(trackerId: trackerId, date: selectedDate))
        }

        collectionView.reloadData()
    }
    
    private func addTracker(_ tracker: Tracker, to header: String) {
        if let idx = categories.firstIndex(where: { $0.header == header }) {
            let oldCategory = categories[idx]
            let updatedCategory = TrackerCategory(
                header: oldCategory.header,
                trackers: oldCategory.trackers + [tracker]
            )
            var newCategories = categories
            newCategories[idx] = updatedCategory
            categories = newCategories
        } else {
            categories = categories + [TrackerCategory(header: header, trackers: [tracker])]
        }
    }
    
    @objc
    private func didTapPlusButton() {
        let createVC = NewHabitViewController()
        createVC.delegate = self

        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }
        
    private func isCompleted(trackerId: UUID) -> Bool {
        completedTrackers.contains {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    private func completionsCount(trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
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
        collectionView.backgroundColor = .systemBackground

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
        
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8)
        ])
    }
}
