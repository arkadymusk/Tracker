//
//  TrackerCompletionStore.swift
//  Tracker
//
//  Created by Аркадий Червонный on 15.03.2026.
//

import Foundation

final class TrackerCompletionStore {
    private let userDefaults = UserDefaults.standard
    private let key = "tracker_completion_records"

    func fetchRecords() -> [TrackerRecord] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([TrackerRecord].self, from: data)) ?? []
    }

    func saveRecords(_ records: [TrackerRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        userDefaults.set(data, forKey: key)
    }

    func toggleRecord(trackerId: UUID, date: Date) {
        var records = fetchRecords()

        if let index = records.firstIndex(where: {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            records.remove(at: index)
        } else {
            records.append(TrackerRecord(trackerId: trackerId, date: date))
        }

        saveRecords(records)
    }

    func isCompleted(trackerId: UUID, date: Date) -> Bool {
        fetchRecords().contains {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func completionsCount(for trackerId: UUID) -> Int {
        fetchRecords().filter { $0.trackerId == trackerId }.count
    }

    func totalCompletedCount() -> Int {
        fetchRecords().count
    }
}
