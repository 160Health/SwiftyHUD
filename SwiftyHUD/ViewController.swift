//
//  ViewController.swift
//  Copyright © 2024 91160.com. All rights reserved.
//
//  Created by Aimee on 2024/1/23.
//

import UIKit

class ViewController: UIViewController {
    private lazy var topButton = makeButton(title: "Top", action: #selector(actionShowHUD(_:)))
    private lazy var centerButton = makeButton(title: "Center", action: #selector(actionShowHUD(_:)))
    private lazy var bottomButton = makeButton(title: "Bottom", action: #selector(actionShowHUD(_:)))
    private lazy var naviButton = makeButton(title: "NavigationBarMask", action: #selector(actionShowHUD(_:)))
    private lazy var tabButton = makeButton(title: "TabBarMask", action: #selector(actionShowHUD(_:)))
    private lazy var tesstButton = makeButton(title: "Test", action: #selector(actionTest))
    
    var count = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HUD"
        
        view.addSubview(topButton)
        view.addSubview(centerButton)
        view.addSubview(bottomButton)
        view.addSubview(naviButton)
        view.addSubview(tabButton)
        view.addSubview(tesstButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topButton.frame = CGRect(x: (UIScreen.main.bounds.width - 160) / 2, y: UIWindow.hudstatusBarHeight + 44 + 16, width: 160, height: 44)
        centerButton.frame = CGRect(x: (UIScreen.main.bounds.width - 160) / 2, y: topButton.frame.maxY + 16, width: 160, height: 44)
        bottomButton.frame = CGRect(x: (UIScreen.main.bounds.width - 160) / 2, y: centerButton.frame.maxY + 16, width: 160, height: 44)
        naviButton.frame = CGRect(x: (UIScreen.main.bounds.width - 160) / 2, y: bottomButton.frame.maxY + 16, width: 160, height: 44)
        tabButton.frame = CGRect(x: (UIScreen.main.bounds.width - 160) / 2, y: naviButton.frame.maxY + 16, width: 160, height: 44)
        tesstButton.frame = CGRect(x: (UIScreen.main.bounds.width - 160) / 2, y: tabButton.frame.maxY + 16, width: 160, height: 44)
    }
    
    @objc private func actionShowHUD(_ sender: UIButton) {
        let title = sender.title(for: .normal)!
        let position = HUDPosition(rawValue: title.prefix(1).lowercased() + title.suffix(title.count - 1))!
        HUD.contentBackgroundColor = .clear
        HUD.contentStyle = .dark
        HUD.show(status: .success, title: title + " \(count)", subtitle: Array(repeating: title, count: 4).joined(separator: " "), direction: .horizontal, position: position)
        count += 1
    }
    
    @objc private func actionTest() {
        let position = HUDPosition.center
        HUD.contentTranslucent = true
        HUD.contentBackgroundColor = .systemRed
        HUD.contentStyle = .light
        
        print(times)
        
        var task: HUDTask?
        
        if times == 1 {
            HUD.backgroundColor = UIColor(white: 0, alpha: 0.5)
            task = HUD.showLoading(progress: -1, title: "Loading...", subtitle: "hello hello hello hello hello hello hello hello hello hello hello", direction: .horizontal, position: position, cancelable: false)
            task?.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionTest)))
            
            times += 1
        } else if times == 2 {
            HUD.backgroundColor = UIColor(white: 0, alpha: 0.5)
            HUD.showLoading(progress: 0.5, subtitle: "hello", direction: .horizontal, position: position)
            times += 1
        } else if times == 3 {
            HUD.backgroundColor = UIColor(white: 0, alpha: 0.5)
            HUD.showLoading(progress: -1, title: "Loading...", subtitle: "hello hello hello hello hello hello hello hello hello hello hello", direction: .horizontal, position: position, cancelable: true)
            times += 1
        } else if times == 4 {
            HUD.backgroundColor = .clear
            HUD.show(status: .error, title: "Error", direction: .horizontal, position: position, closeable: true)
            
            times += 1
        } else if times == 5 {
            HUD.show(status: .none, title: "Info", direction: .horizontal, priority: .sequence, position: position, closeable: true)
            
            times += 1
        } else {
            times = 1
        }
    }
    
    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    var times = 1
}

