//
//  TabBarController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 28.01.2026.
//
import UIKit
import Foundation

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .appBackground)
        appearance.shadowColor = UIColor.separator
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        let trackersVS = TrackersViewController()
        trackersVS.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.trackers.title", comment: ""),
            image: UIImage(named: "tabBarCircle"),
            selectedImage: nil
        )
        
        let statsVS = StatisticsViewController()
        statsVS.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.stats.title", comment: ""),
            image: UIImage(named: "tabBarHare"),
            selectedImage: nil
        )
        
        let trackersNav = UINavigationController(rootViewController: trackersVS)
        let statsNav = UINavigationController(rootViewController: statsVS)
        
        self.viewControllers = [trackersNav, statsNav]
    }
}
