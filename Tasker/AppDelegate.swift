//
//  AppDelegate.swift
//  Tasker
//
//  Created by viscontti on 04.08.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        let mainViewController = MainViewController()
    
        
        mainViewController.title = "Tasker"
        navigationController.setViewControllers([mainViewController], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true

    }
}

