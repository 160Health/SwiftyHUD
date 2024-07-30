//
//  HUD+Extension.swift
//  Copyright © 2024 91160.com. All rights reserved.
//
//  Created by Aimee on 2024/07/27.
//

import UIKit

// String extension to create an attributed string with a specified font
extension String {
    func attributedString(with font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [.font: font])
    }
}

// NSAttributedString extension to calculate the size of the text given a bounding size
extension NSAttributedString {
    func textSize(with size: CGSize) -> CGSize {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingRect = boundingRect(with: size, options: options, context: nil)
        return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
}

// DispatchQueue extension to ensure code runs on the main thread
extension DispatchQueue {
    static func runInMainThreadSync(_ function: @escaping () -> Void) {
        if Thread.isMainThread {
            function()
        } else {
            DispatchQueue.main.sync {
                function()
            }
        }
    }
}

// UIWindow extension to access key window and status bar height
extension UIWindow {
    static var hudkeyWindow: UIWindow? {
        // Retrieve the first key window from the application's windows
        if let window = UIApplication.shared.windows.first, window.isKeyWindow {
            return window
        }
        // Fallback to the application's key window if the first window is not available
        if let window = UIApplication.shared.keyWindow, window.isKeyWindow {
            return window
        }
        // Fallback to the delegate's window if available
        if let delegate = UIApplication.shared.delegate, let window = delegate.window as? UIWindow {
            return window
        }
        // Return nil if no key window is found
        return nil
    }
    
    // Calculate the status bar height
    static var hudstatusBarHeight: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return 0
        }
        var height: CGFloat = 0
        let insets: UIEdgeInsets = hudkeyWindow!.safeAreaInsets
        height = insets.top
        // Fallback to different methods based on iOS version
        if height == 0 {
            if #available(iOS 13.0, *) {
                height = hudkeyWindow!.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 20
            } else {
                height = UIApplication.shared.statusBarFrame.size.height
            }
        }
        // Default to 20 if no height is determined
        if height == 0 {
            height = 20
        }
        return height
    }
    
    // Calculate the bottom inset
    static var hudbottomInset: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return 0
        }
        return _hudsafeAreaInsets.bottom
    }
    
    // Access the safe area insets of the key window
    static var _hudsafeAreaInsets: UIEdgeInsets {
        return hudkeyWindow!.safeAreaInsets
    }
}
