//
//  HUDView.swift
//  Copyright © 2024 91160.com. All rights reserved.
//
//  Created by Aimee on 2024/07/27.
//

import UIKit

// HUDView is a custom UIView that represents the visual representation of a HUD (Heads-Up Display)
// which can show loading indicators, messages, progress, etc.
class HUDView: UIView {
    // UI components of the HUD
    private var blurView: UIVisualEffectView?
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // A custom view to represent progress, could be a spinner or progress bar
    private lazy var progressView: ProgressView = {
        let progressView = ProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        return progressView
    }()
    
    // Image view to display icons or images
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // Label for the main text message
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = HUD.contentStyle == .dark ? .white : UIColor(white: 0.2, alpha: 1)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    // Label for the secondary text message
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(white: HUD.contentStyle == .dark ? 1 : 0.2, alpha: 0.7)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    // Close button to dismiss the HUD
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = HUD.contentStyle == .dark ? .white : UIColor(white: 0.2, alpha: 1)
        button.setImage(UIImage(named: "HUDIconClose"), for: .normal)
        button.addTarget(self, action: #selector(actionClose), for: .touchUpInside)
        return button
    }()
    
    // Cancel button to provide a way to cancel ongoing operations
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = HUD.contentStyle == .dark ? .white : UIColor(white: 0.2, alpha: 1)
        button.setBackgroundImage(UIImage(named: "HUDBgCancel"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(actionCancel), for: .touchUpInside)
        return button
    }()
    
    // Cached sizes for title and subtitle to use in layout calculations
    private var titleSize: CGSize = .zero
    private var subtitleSize: CGSize = .zero
    
    // Origin for the content view, used during animations
    private var originX: CGFloat = 0
    private var originY: CGFloat = 0
    
    // Scale factor for animations
    private let scale: CGFloat = 0.5
    
    // Reference to the task model that this view represents
    var task: HUDTask!
    
    // Initialization with various parameters to customize the HUD's appearance and behavior
    init(superview: UIView,
         progress: CGFloat?,
         image: UIImage? = nil,
         title: String? = nil,
         subtitle: String? = nil,
         direction: HUDDirection = .vertical,
         position: HUDPosition = .center,
         closeable: Bool = false,
         cancelable: Bool = false) {
        super.init(frame: CGRect(x: 0, y: 0, width: 240, height: 120))
        
        backgroundColor = HUD.contentBackgroundColor
        
        if position == .top || position == .center || position == .bottom {
            layer.cornerRadius = 8
        }
        layer.masksToBounds = true
        
        if HUD.contentTranslucent {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: HUD.contentStyle == .dark ? .dark : .extraLight))
            addSubview(blurView!)
        }
        addSubview(topView)
        progressView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        topView.addSubview(progressView)
        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        topView.addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(closeButton)
        addSubview(cancelButton)
        
        if direction == .vertical {
            titleLabel.textAlignment = .center
            subtitleLabel.textAlignment = .center
        } else {
            titleLabel.textAlignment = .left
            subtitleLabel.textAlignment = .left
        }
        
        update(superview: superview,
               progress: progress,
               image: image,
               title: title,
               subtitle: subtitle,
               direction: direction,
               position: position,
               closeable: closeable,
               cancelable: cancelable,
               addToSuperview: false)
    }
    
    // Update the size of the HUD based on its contents and position
    private func updateSize(superview: UIView,
                            progress: CGFloat?,
                            image: UIImage?,
                            title: String?,
                            subtitle: String?,
                            direction: HUDDirection,
                            position: HUDPosition,
                            cancelable: Bool) {
        var width: CGFloat = HUD.minWidth
        var height: CGFloat = HUD.minHeight
        var maxTextHeight: CGFloat = HUD.maxHeight - 32
        
        if direction == .vertical {
            if position == .navigationBarMask || position == .tabBarMask {
                width = superview.bounds.width
                height = (position == .navigationBarMask ? UIWindow.hudstatusBarHeight : UIWindow.hudbottomInset) + 16
                originY = (position == .navigationBarMask ? UIWindow.hudstatusBarHeight : 0) + 16
                
                if progress != nil || image != nil {
                    height += 40
                    maxTextHeight -= 40 + 8
                }
                
                if cancelable {
                    maxTextHeight -= 40 + 8
                }
                
                if title != nil && subtitle != nil {
                    maxTextHeight -= 8
                    maxTextHeight /= 2
                }
                
                if title != nil {
                    let string = title!.attributedString(with: .systemFont(ofSize: 16, weight: .medium))
                    let size = string.textSize(with: CGSize(width: width - 32, height: maxTextHeight))
                    titleSize = size
                    height += 8 + size.height
                } else {
                    titleSize = .zero
                }
                
                if subtitle != nil {
                    let string = subtitle!.attributedString(with: .systemFont(ofSize: 14, weight: .regular))
                    let size = string.textSize(with: CGSize(width: width - 32, height: maxTextHeight))
                    subtitleSize = size
                    height += 8 + size.height
                } else {
                    subtitleSize = .zero
                }
                
                if cancelable {
                    height += 8 + 40
                }
                
                height += 16
            } else {
                width = HUD.minWidth
                height = 16
                originY = 16
                
                if progress != nil || image != nil {
                    height += 40
                    maxTextHeight -= 40 + 8
                }
                
                if cancelable {
                    maxTextHeight -= 40 + 8
                }
                
                if title != nil && subtitle != nil {
                    maxTextHeight -= 8
                    maxTextHeight /= 2
                }
                
                if title != nil {
                    let string = title!.attributedString(with: .systemFont(ofSize: 16, weight: .medium))
                    let size = string.textSize(with: CGSize(width: HUD.maxWidth - 32, height: maxTextHeight))
                    titleSize = size
                    var spacing: CGFloat = 0
                    if progress != nil || image != nil {
                        spacing = 8
                    }
                    height += spacing + size.height
                    if size.height > 24 {
                        width = HUD.maxWidth - 32
                    } else {
                        width = max(size.width, HUD.minWidth - 32)
                    }
                } else {
                    titleSize = .zero
                }
                
                if subtitle != nil {
                    let string = subtitle!.attributedString(with: .systemFont(ofSize: 14, weight: .regular))
                    let size = string.textSize(with: CGSize(width: HUD.maxWidth - 32, height: maxTextHeight))
                    subtitleSize = size
                    var spacing: CGFloat = 0
                    if title != nil {
                        spacing = 8
                    } else {
                        if progress != nil || image != nil {
                            spacing = 8
                        }
                    }
                    height += spacing + size.height
                    if size.height > 24 {
                        width = HUD.maxWidth - 32
                    } else {
                        width = max(size.width, width)
                    }
                } else {
                    subtitleSize = .zero
                }
                
                if cancelable {
                    height += 8 + 40
                }
                
                width += 32
                height += 16
            }
        } else {
            var iconHeight: CGFloat = 0
            var textHeight: CGFloat = 0
            
            if position == .navigationBarMask || position == .tabBarMask {
                var maxTextWidth: CGFloat = superview.bounds.width - 32
                
                width = superview.bounds.width
                height = (position == .navigationBarMask ? UIWindow.hudstatusBarHeight : UIWindow.hudbottomInset) + 16
                originX = 16
                originY = (position == .navigationBarMask ? UIWindow.hudstatusBarHeight : 0) + 16
                
                if progress != nil || image != nil {
                    maxTextWidth -= 40 + 8
                    iconHeight = 40
                }
                
                if cancelable {
                    maxTextWidth -= HUD.cancelButtonMinWidth + 8
                    iconHeight = 40
                }
                
                if title != nil && subtitle != nil {
                    maxTextHeight -= 8
                    maxTextHeight /= 2
                }
                
                if title != nil {
                    let string = title!.attributedString(with: .systemFont(ofSize: 16, weight: .medium))
                    let size = string.textSize(with: CGSize(width: maxTextWidth, height: maxTextHeight))
                    titleSize = size
                    textHeight = size.height
                } else {
                    titleSize = .zero
                }
                
                if subtitle != nil {
                    let string = subtitle!.attributedString(with: .systemFont(ofSize: 14, weight: .regular))
                    let size = string.textSize(with: CGSize(width: maxTextWidth, height: maxTextHeight))
                    subtitleSize = size
                    textHeight += (titleSize.height > 0 ? 8 : 0) + size.height
                } else {
                    subtitleSize = .zero
                }
                
                height += max(iconHeight, textHeight)
                
                if iconHeight > textHeight {
                    originY += (iconHeight - textHeight) * 0.5
                }
                
                height += 16
            } else {
                var maxTextWidth: CGFloat = HUD.maxWidth - 32
                
                width = 16
                height = 16
                originX = 16
                originY = 16
                var textWidth: CGFloat = 0
                
                if progress != nil || image != nil {
                    iconHeight = 40
                    maxTextWidth -= 40 + 8
                    width += 40
                }
                
                if cancelable {
                    iconHeight = 40
                    maxTextWidth -= HUD.cancelButtonMinWidth + 8
                    width += HUD.cancelButtonMinWidth + 8
                }
                
                if title != nil && subtitle != nil {
                    maxTextHeight -= 8
                    maxTextHeight /= 2
                }
                
                if title != nil {
                    let string = title!.attributedString(with: .systemFont(ofSize: 16, weight: .medium))
                    let size = string.textSize(with: CGSize(width: maxTextWidth, height: maxTextHeight))
                    titleSize = size
                    textWidth = size.width
                    textHeight = size.height
                } else {
                    titleSize = .zero
                }
                
                if subtitle != nil {
                    let string = subtitle!.attributedString(with: .systemFont(ofSize: 14, weight: .regular))
                    let size = string.textSize(with: CGSize(width: maxTextWidth, height: maxTextHeight))
                    subtitleSize = size
                    textWidth = max(textWidth, size.width)
                    textHeight += (titleSize.height > 0 ? 8 : 0) + size.height
                } else {
                    subtitleSize = .zero
                }
                
                if textWidth > 0 {
                    width += textWidth + 8
                }
                
                width += 16
                
                width = max(HUD.minWidth, width)
                
                if width < HUD.minWidth {
                    originX += (HUD.minWidth - width) * 0.5
                }
                
                if titleSize == .zero && subtitleSize == .zero && !cancelable {
                    originX = (width - 40) * 0.5
                }
                
                height += max(iconHeight, textHeight)
                
                if iconHeight > textHeight {
                    originY += (iconHeight - textHeight) * 0.5
                }
                
                height += 16
            }
        }
        
        if position == .navigationBarMask {
            frame.size = CGSize(width: width, height: max(height, UIWindow.hudstatusBarHeight + 44))
        } else if position == .tabBarMask {
            frame.size = CGSize(width: width, height: max(height, UIWindow.hudbottomInset + 49))
        } else {
            frame.size = CGSize(width: width, height: max(height, HUD.minHeight))
        }
        
        blurView?.frame = bounds
    }
    
    // Update the visual representation of the progress or image
    private func update(progress: CGFloat?, image: UIImage?, direction: HUDDirection, position: HUDPosition) {
        if direction == .vertical {
            topView.frame = CGRect(x: (bounds.width - 40) * 0.5, y: originY, width: 40, height: 40)
            if progress != nil || image != nil {
                originY += 40 + 8
            }
        } else {
            if position == .navigationBarMask {
                topView.frame = CGRect(x: originX, y: UIWindow.hudstatusBarHeight + (bounds.height - UIWindow.hudstatusBarHeight - 40) * 0.5, width: 40, height: 40)
            } else if position == .tabBarMask {
                topView.frame = CGRect(x: originX, y: (bounds.height - UIWindow.hudbottomInset - 40) * 0.5, width: 40, height: 40)
            } else {
                topView.frame = CGRect(x: originX, y: (bounds.height - 40) * 0.5, width: 40, height: 40)
            }
            if progress != nil || image != nil {
                originX += 40 + 8
            }
        }
        
        if let progress {
            progressView.alpha = 1
            progressView.progress = progress
            
            imageView.alpha = 0
            imageView.image = nil
        } else if let image {
            progressView.alpha = 0
            progressView.progress = 0
            
            imageView.alpha = 1
            imageView.image = image
        } else {
            progressView.alpha = 0
            progressView.progress = 0
            
            imageView.alpha = 0
            imageView.image = nil
        }
    }
    
    // Update the title label with the provided text and layout it appropriately
    private func updateTitle(_ title: String?, direction: HUDDirection, position: HUDPosition) {
        if direction == .vertical {
            titleLabel.textAlignment = .center
            titleLabel.frame = CGRect(x: (bounds.width - titleSize.width) * 0.5, y: originY, width: titleSize.width, height: titleSize.height)
        } else {
            titleLabel.frame = CGRect(x: originX, y: originY, width: titleSize.width, height: titleSize.height)
        }
        
        if let title {
            titleLabel.alpha = 1
            titleLabel.text = title
            
            originY += titleSize.height + 8
        } else {
            titleLabel.alpha = 0
            titleLabel.text = nil
        }
    }
    
    // Update the subtitle label with the provided text and layout it appropriately
    private func updateSubtitle(_ subtitle: String?, direction: HUDDirection, position: HUDPosition) {
        if direction == .vertical {
            subtitleLabel.textAlignment = .center
            subtitleLabel.frame = CGRect(x: (bounds.width - subtitleSize.width) * 0.5, y: originY, width: subtitleSize.width, height: subtitleSize.height)
        } else {
            subtitleLabel.frame = CGRect(x: originX, y: originY, width: subtitleSize.width, height: subtitleSize.height)
        }
        
        if let subtitle {
            subtitleLabel.alpha = 1
            subtitleLabel.text = subtitle
            
            originY += subtitleSize.height + 8
        } else {
            subtitleLabel.alpha = 0
            subtitleLabel.text = nil
        }
    }
    
    // Show or hide the close button based on the 'closeable' parameter
    private func updateCloseable(_ closeable: Bool, direction: HUDDirection, position: HUDPosition) {
        closeButton.frame = CGRect(x: bounds.width - 40, y: position == .navigationBarMask ? UIWindow.hudstatusBarHeight : 0, width: 40, height: 40)
        
        if closeable {
            closeButton.alpha = 1
        } else {
            closeButton.alpha = 0
        }
    }
    
    // Show or hide the cancel button based on the 'cancelable' parameter
    private func updateCancelable(_ cancelable: Bool, direction: HUDDirection, position: HUDPosition) {
        if direction == .vertical {
            cancelButton.frame = CGRect(x: 16, y: originY, width: bounds.width - 32, height: 40)
        } else {
            if position == .navigationBarMask {
                cancelButton.frame = CGRect(x: bounds.width - HUD.cancelButtonMinWidth - 16, y: UIWindow.hudstatusBarHeight + (bounds.height - UIWindow.hudstatusBarHeight - 40) * 0.5, width: HUD.cancelButtonMinWidth, height: 40)
            } else if position == .tabBarMask {
                cancelButton.frame = CGRect(x: bounds.width - HUD.cancelButtonMinWidth - 16, y: (bounds.height - UIWindow.hudbottomInset - 40) * 0.5, width: HUD.cancelButtonMinWidth, height: 40)
            } else {
                cancelButton.frame = CGRect(x: bounds.width - HUD.cancelButtonMinWidth - 16, y: (bounds.height - 40) * 0.5, width: HUD.cancelButtonMinWidth, height: 40)
            }
        }
        
        if cancelable {
            cancelButton.alpha = 1
        } else {
            cancelButton.alpha = 0
        }
    }
    
    // Deinitializer to log when a HUDView instance is deallocated
    deinit {
        print("HUDView deinit")
    }
    
    // Required initializer for decoding the view from a storyboard or nib
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Update the HUD with new content and layout it within the provided superview
    func update(superview: UIView,
                progress: CGFloat?,
                image: UIImage? = nil,
                title: String? = nil,
                subtitle: String? = nil,
                direction: HUDDirection = .vertical,
                position: HUDPosition = .center,
                closeable: Bool = false,
                cancelable: Bool = false,
                backgroundInteractive: Bool = false,
                addToSuperview: Bool) {
        updateSize(superview: superview, progress: progress, image: image, title: title, subtitle: subtitle, direction: direction, position: position, cancelable: cancelable)
        
        if self.superview == superview {
            switch position {
            case .top:
                center.x = superview.center.x
            case .center:
                center = superview.center
            case .bottom:
                center.x = superview.center.x
                frame.origin.y = superview.bounds.height - frame.height - UIWindow.hudbottomInset - 49 - 8
            case .navigationBarMask:
                break
            case .tabBarMask:
                frame.origin.y = superview.bounds.height - frame.height
            }
        } else {
            switch position {
            case .top:
                center.x = superview.center.x
                frame.origin.y = -frame.height
            case .center:
                center = superview.center
            case .bottom:
                center.x = superview.center.x
                frame.origin.y = superview.bounds.height
            case .navigationBarMask:
                frame.origin = CGPoint(x: 0, y: -frame.height)
            case .tabBarMask:
                frame.origin = CGPoint(x: 0, y: superview.bounds.height)
            }
        }
        
        if addToSuperview {
            if self.superview != superview {
                HUD.backgroundView?.removeFromSuperview()
                removeFromSuperview()
            }
            
            if HUD.backgroundView == nil {
                HUD.backgroundView = UIView()
            }
            HUD.backgroundView?.frame = superview.bounds
            HUD.backgroundView?.backgroundColor = HUD.backgroundColor
            HUD.backgroundView?.isUserInteractionEnabled = !backgroundInteractive
            superview.addSubview(HUD.backgroundView!)
            superview.addSubview(self)
        }
        
        update(progress: progress, image: image, direction: direction, position: position)
        updateTitle(title, direction: direction, position: position)
        
        if title == nil {
            subtitleLabel.textColor = titleLabel.textColor
        }
        updateSubtitle(subtitle, direction: direction, position: position)
        updateCloseable(closeable, direction: direction, position: position)
        updateCancelable(cancelable, direction: direction, position: position)
    }
    
    // Show the HUD view with animations
    @objc func show() {
        if task.superview != superview {
            HUD.backgroundView?.removeFromSuperview()
            removeFromSuperview()
        }
        if HUD.backgroundView == nil {
            HUD.backgroundView = UIView()
        }
        HUD.backgroundView?.frame = task.superview.bounds
        HUD.backgroundView?.backgroundColor = .clear
        HUD.backgroundView?.isUserInteractionEnabled = !task.backgroundInteractive
        task.superview.addSubview(HUD.backgroundView!)
        task.superview.addSubview(self)
        
        if task.position == .center {
            alpha = 0
            transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        task.willShowBlock?()
        
        HUD.animate(true) {
            HUD.backgroundView?.backgroundColor = HUD.backgroundColor
            
            switch self.task.position {
            case .top:
                self.frame.origin.y = UIWindow.hudstatusBarHeight
            case .center:
                self.alpha = 1
                self.transform = .identity
            case .bottom:
                self.frame.origin.y = self.superview!.bounds.height - self.frame.height - UIWindow.hudbottomInset - 57
            case .navigationBarMask:
                self.frame.origin.y = 0
            case .tabBarMask:
                self.frame.origin.y = self.superview!.bounds.height - self.frame.height
            }
        } completion: {
            self.task.didShowBlock?()
            
            if self.task.duration > 0 {
                self.perform(#selector(HUDView.hide), with: nil, afterDelay: self.task.duration, inModes: [.common])
            }
        }
    }
    
    // Hide the HUD view with animations and completion block
    @objc func hide(completion: @escaping HUDBlock) {
        HUD.cancelPreviousPerformRequests(withTarget: self)
        
        if let task {
            task.willHideBlock?()
            
            HUD.animate(true) {
                HUD.backgroundView?.backgroundColor = .clear
                
                switch self.task.position {
                case .top:
                    self.frame.origin.y = -self.frame.height
                case .center:
                    self.alpha = 0
                    self.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                case .bottom:
                    self.frame.origin.y = self.superview!.bounds.height
                case .navigationBarMask:
                    self.frame.origin.y = -self.frame.height
                case .tabBarMask:
                    self.frame.origin.y = self.superview!.bounds.height
                }
            } completion: {
                self.task.didHideBlock?()
                
                HUD.backgroundView?.removeFromSuperview()
                HUD.backgroundView = nil
                
                self.removeFromSuperview()
                
                HUD.removeTaskAndCheckSequenceTasks(&self.task)
            }
        }
    }
    
    // Action triggered when the close button is tapped
    @objc private func actionClose() {
        task.closeAction?()
        HUD.hide(task)
    }
    
    // Action triggered when the cancel button is tapped
    @objc private func actionCancel() {
        task.cancelAction?()
        HUD.hide(task)
    }
}
