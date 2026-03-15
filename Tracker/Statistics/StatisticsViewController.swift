//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 27.01.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    private let completionStore = TrackerCompletionStore()

    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()

    private let cardView = UIView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = NSLocalizedString("statistics.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true

        setupPlaceholder()
        setupCard()
        setupConstraints()
        reloadUI()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatisticsChanged),
            name: .statisticsDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUI()
    }

    @objc
    private func handleStatisticsChanged() {
        reloadUI()
    }

    private func reloadUI() {
        let completedCount = completionStore.totalCompletedCount()
        let hasStatistics = completedCount > 0

        placeholderImageView.isHidden = hasStatistics
        placeholderLabel.isHidden = hasStatistics

        cardView.isHidden = !hasStatistics
        valueLabel.text = "\(completedCount)"
    }

    private func setupPlaceholder() {
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.image = UIImage(resource: .smile)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = NSLocalizedString("statistics.placeholder", comment: "")
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center

        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }

    private func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemBlue.cgColor
        cardView.backgroundColor = UIColor(named: "AppBackground") ?? .black

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.text = NSLocalizedString("statistics.completed", comment: "")

        view.addSubview(cardView)
        cardView.addSubview(valueLabel)
        cardView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),

            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            valueLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
}
