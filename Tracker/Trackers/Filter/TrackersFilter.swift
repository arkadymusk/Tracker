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
            return "Все трекеры"
        case .today:
            return "Трекеры на сегодня"
        case .completed:
            return "Завершённые"
        case .uncompleted:
            return "Не завершённые"
        }
    }
}
