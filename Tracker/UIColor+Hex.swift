//
//  UIColor+Hex.swift
//  Tracker
//
//  Created by Аркадий Червонный on 17.02.2026.
//

import UIKit

extension UIColor {
    convenience init(_ hex: UInt32) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255,
            blue: CGFloat(hex & 0x0000FF) / 255,
            alpha: 1
        )
    }

    func toHex() -> UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = UInt32(red * 255) << 16
        let g = UInt32(green * 255) << 8
        let b = UInt32(blue * 255)
        return r | g | b
    }
}
