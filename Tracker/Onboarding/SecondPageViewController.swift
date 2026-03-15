//
//  SecondPageViewController.swift
//  Tracker
//
//  Created by Аркадий Червонный on 09.03.2026.
//

import UIKit

final class SecondPageViewController: UIViewController {
    
    let backgroundImage = UIImageView()
    let doneButton = UIButton(type: .system)
    let textLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(backgroundImage)
        view.addSubview(doneButton)
        view.addSubview(textLabel)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        backgroundImage.image = UIImage(resource: .secondPageOnboarding)
        
        doneButton.setTitle(NSLocalizedString("secondPage.doneButton.title", comment: ""), for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.backgroundColor = .black
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        textLabel.text = NSLocalizedString("secondPage.title", comment: "")
        textLabel.font = .systemFont(ofSize: 32, weight: .bold)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -160),
            textLabel.heightAnchor.constraint(equalToConstant: 120)

        ])
    }
    
    @objc
    private func didTapDone() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
            
        let tabBarController = TabBarController()
        UIView.transition(with: window,
                            duration: 0.3,
                            options: [.transitionCrossDissolve],
                            animations: {
            window.rootViewController = tabBarController
        })
    }
}
