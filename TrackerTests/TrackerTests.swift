//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Аркадий Червонный on 27.01.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTrackersViewController_light() {
        let vc = TrackersViewController()

        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }

    func testTrackersViewController_dark() {
        let vc = TrackersViewController()

        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
