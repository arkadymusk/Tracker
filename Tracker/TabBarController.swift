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
        
        let trackersVS = TrackersViewController()
        trackersVS.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tabBarCircle"),
            selectedImage: nil
        )
        
        let statsVS = StatisticsViewController()
        statsVS.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tabBarHare"),
            selectedImage: nil
        )
        
        let trackersNav = UINavigationController(rootViewController: trackersVS)
        let statsNav = UINavigationController(rootViewController: statsVS)
        
        self.viewControllers = [trackersNav, statsNav]
    }
}
