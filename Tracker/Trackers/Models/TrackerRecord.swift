//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Аркадий Червонный on 12.02.2026.
//

import Foundation

struct TrackerRecord: Codable, Hashable {
    let trackerId: UUID
    let date: Date
}
