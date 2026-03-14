//
//  TrackerCell.swift
//  Tracker
//
//  Created by Аркадий Червонный on 09.02.2026.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseId = "TrackerCell"

    var onToggle: (() -> Void)?

    private let cardView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()

    private let daysLabel = UILabel()
    private let plusButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setupUI() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        cardView.addSubview(emojiLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .label
        contentView.addSubview(daysLabel)

        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.layer.cornerRadius = 17
        plusButton.clipsToBounds = true
        plusButton.tintColor = .white
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
        contentView.addSubview(plusButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),

            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    @objc
    private func didTapPlus() {
        onToggle?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
    }

    private func daysText(_ days: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("tracker.daysCount", comment: ""),
            days
        )
    }
    func configure(title: String,
                   emoji: String,
                   cardColor: UIColor,
                   totalCompletions: Int,
                   isCompletedForSelectedDate: Bool,
                   canComplete: Bool) {

        cardView.backgroundColor = cardColor
        emojiLabel.text = emoji
        titleLabel.text = title

        daysLabel.text = daysText(totalCompletions)

        plusButton.backgroundColor = cardColor

        let imageName = isCompletedForSelectedDate ? "checkmark" : "plus"
        plusButton.setImage(UIImage(systemName: imageName), for: .normal)
        plusButton.alpha = isCompletedForSelectedDate ? 0.6 : 1.0
        
        plusButton.isEnabled = canComplete
        plusButton.alpha = canComplete ? plusButton.alpha : 0.3
    }
}
