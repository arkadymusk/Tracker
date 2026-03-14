//
//  TrackerModels.swift
//  Tracker
//
//  Created by Аркадий Червонный on 04.02.2026.
//

import UIKit

enum Weekday: Int, CaseIterable, Hashable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
        switch self {
        case .monday: return NSLocalizedString("weekDay.title.monday", comment: "")
        case .tuesday: return NSLocalizedString("weekDay.title.tuesday", comment: "")
        case .wednesday: return NSLocalizedString("weekDay.title.wednesday", comment: "")
        case .thursday: return NSLocalizedString("weekDay.title.thursday", comment: "")
        case .friday: return NSLocalizedString("weekDay.title.friday", comment: "")
        case .saturday: return NSLocalizedString("weekDay.title.saturday", comment: "")
        case .sunday: return NSLocalizedString("weekDay.title.sunday", comment: "")
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: return NSLocalizedString("weekDay.shortTitle.monday", comment: "")
        case .tuesday: return NSLocalizedString("weekDay.shortTitle.tuesday", comment: "")
        case .wednesday: return NSLocalizedString("weekDay.shortTitle.wednesday", comment: "")
        case .thursday: return NSLocalizedString("weekDay.shortTitle.thursday", comment: "")
        case .friday: return NSLocalizedString("weekDay.shortTitle.friday", comment: "")
        case .saturday: return NSLocalizedString("weekDay.shortTitle.saturday", comment: "")
        case .sunday: return NSLocalizedString("weekDay.shortTitle.sunday", comment: "")
        }
    }
}



