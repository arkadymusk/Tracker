//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Аркадий Червонный on 27.01.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let hasSeenOnboardingKey = "hasSeenOnboarding"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
        
        if hasSeenOnboarding {
            window?.rootViewController = TabBarController()
        } else {
            window?.rootViewController = OnboardingPageViewController()
        }
        
        window?.makeKeyAndVisible()
    }
}

