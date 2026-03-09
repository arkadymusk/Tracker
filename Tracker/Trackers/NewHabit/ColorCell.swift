//
//  ColorCell.swift
//  Tracker
//
//  Created by Аркадий Червонный on 17.02.2026.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"
    
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        colorView.layer.cornerRadius = 8
        colorView.clipsToBounds = true
        
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func configure(color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        layer.borderColor = isSelected ? UIColor.systemGray5.cgColor : UIColor.clear.cgColor
    }
}
