//
//  EmojiCell.swift
//  Tracker
//
//  Created by Аркадий Червонный on 17.02.2026.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseId = "EmojiCell"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(emoji: String, isSelected: Bool) {
        label.text = emoji
        contentView.backgroundColor = isSelected ? .systemGray5 : .clear
    }
}
