//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Аркадий Червонный on 16.03.2026.
//

import AppMetricaCore
import Foundation

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

enum AnalyticsService {
    static func report(event: AnalyticsEvent,
                       screen: AnalyticsScreen,
                       item: AnalyticsItem? = nil) {
        var parameters: [String: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]

        if let item {
            parameters["item"] = item.rawValue
        }

        AppMetrica.reportEvent(name: "event", parameters: parameters) { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        }

        print("ANALYTICS EVENT:", parameters)
    }
}
