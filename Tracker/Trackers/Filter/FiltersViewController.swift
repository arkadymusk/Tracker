//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 15.03.2026.
//

import UIKit

final class FiltersViewController: UIViewController {
    var onFilterSelected: ((TrackersFilter) -> Void)?

    private let selectedFilter: TrackersFilter
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(selectedFilter: TrackersFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("filtres.title", comment: "")

        setupTableView()
        setupConstraints()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackersFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let filter = TrackersFilter.allCases[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "FilterCell")

        cell.textLabel?.text = filter.title
        cell.backgroundColor = .secondarySystemBackground
        cell.selectionStyle = .none

        if filter == selectedFilter && filter != .all && filter != .today {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }

        let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1
        if indexPath.row == lastRow {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = TrackersFilter.allCases[indexPath.row]
        onFilterSelected?(filter)
        dismiss(animated: true)
    }
}
