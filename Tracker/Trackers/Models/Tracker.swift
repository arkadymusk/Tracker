//
//  Tracker.swift
//  Tracker
//
//  Created by Аркадий Червонный on 12.02.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}
