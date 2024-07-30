//
//  AppDelegate.swift
//  Copyright © 2024 91160.com. All rights reserved.
//
//  Created by Aimee on 2024/1/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tabBarController: UITabBarController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        tabBarController = UITabBarController()
        let navi = UINavigationController(rootViewController: ViewController())
        tabBarController.viewControllers = [navi]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}
