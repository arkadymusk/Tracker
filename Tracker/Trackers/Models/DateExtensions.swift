//
//  DateExtensions.swift
//  Tracker
//
//  Created by Аркадий Червонный on 11.02.2026.
//

import Foundation

extension Date {
    func weekday() -> Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: self)
        switch weekdayNumber {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .sunday
        }
    }
}
