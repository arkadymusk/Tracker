//
//  TrackersFilter.swift
//  Tracker
//
//  Created by Аркадий Червонный on 15.03.2026.
//

import Foundation

enum TrackersFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filtres.all", comment: "")
        case .today:
            return NSLocalizedString("filtres.today", comment: "")
        case .completed:
            return NSLocalizedString("filtres.completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("filtres.uncompleted", comment: "")
        }
    }
}
