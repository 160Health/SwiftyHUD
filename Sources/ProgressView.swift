//
//  ProgressView.swift
//  Copyright © 2024 91160.com. All rights reserved.
//
//  Created by Aimee on 2024/07/27.
//

import UIKit

// Custom UIView subclass to display a circular progress indicator
class ProgressView: UIView {
    // Minimum and maximum stroke lengths for the animated circle
    var minStrokeLength: CGFloat = 0.05 {
        didSet {
            // If progress is -1, restart the animation with new minStrokeLength
            if progress == -1 {
                stopAnimating()
                circleLayer.strokeEnd = minStrokeLength
                startAnimating()
            }
        }
    }
    var maxStrokeLength: CGFloat = 0.7 {
        didSet {
            // If progress is -1, restart the animation with new maxStrokeLength
            if progress == -1 {
                stopAnimating()
                circleLayer.strokeEnd = minStrokeLength
                startAnimating()
            }
        }
    }
    // Line width of the animated circle
    var circleLineWidth: CGFloat = 3 {
        didSet {
            // Update the path and line width of the circle layer
            circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            circleLayer.lineWidth = circleLineWidth
        }
    }
    // Color of the animated circle
    var circleColor: UIColor = .white {
        didSet {
            // Update the stroke color of the circle layer
            circleLayer.strokeColor = circleColor.cgColor
        }
    }
    // Line width of the background circle
    var circleBackgroudLineWidth: CGFloat = 5 {
        didSet {
            // Update the path and line width of the background circle layer
            circleBackgroudLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleBackgroudLineWidth / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            circleBackgroudLayer.lineWidth = circleBackgroudLineWidth
            
            circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            circleLayer.lineWidth = circleLineWidth
        }
    }
    // Color of the background circle
    var circleBackgroudColor: UIColor = UIColor(white: 0, alpha: 0.5) {
        didSet {
            // Update the stroke color of the background circle layer
            circleBackgroudLayer.strokeColor = circleBackgroudColor.cgColor
        }
    }
    // Progress value, controls the stroke end position of the animated circle
    var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.stopAnimating()
                
                if self.progress == -1 {
                    // Special case for infinite animation
                    self.circleLayer.strokeEnd = self.minStrokeLength
                    self.startAnimating()
                } else {
                    // Set strokeEnd to match the progress value
                    self.circleLayer.strokeEnd = self.progress
                }
            }
        }
    }
    
    // CAShapeLayer for the background circle
    private let circleBackgroudLayer = CAShapeLayer()
    // CAShapeLayer for the animated circle
    private let circleLayer = CAShapeLayer()
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        initcircleBackgroudLayer()
        initShapeLayer()
    }
    
    // Layout subviews to adjust layers based on the view's bounds
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if circleBackgroudLayer.frame.width != frame.width {
            circleBackgroudLayer.frame = bounds
            circleBackgroudLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleBackgroudLineWidth / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
            
            circleLayer.frame = bounds
            circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initialize the background circle layer
    private func initcircleBackgroudLayer() {
        circleBackgroudLayer.backgroundColor = UIColor.clear.cgColor
        circleBackgroudLayer.strokeColor = circleBackgroudColor.cgColor
        circleBackgroudLayer.fillColor = UIColor.clear.cgColor
        circleBackgroudLayer.lineWidth = circleBackgroudLineWidth
        circleBackgroudLayer.frame = bounds
        circleBackgroudLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleBackgroudLineWidth / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
        layer.addSublayer(circleBackgroudLayer)
    }
    
    // Initialize the animated circle layer
    func initShapeLayer() {
        circleLayer.actions = ["strokeEnd" : NSNull(),
                               "strokeStart" : NSNull(),
                               "transform" : NSNull()]
        circleLayer.backgroundColor = UIColor.clear.cgColor
        circleLayer.strokeColor = circleColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = circleLineWidth
        circleLayer.lineCap = .round
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0
        circleLayer.frame = bounds
        circleLayer.path = UIBezierPath(arcCenter: bounds.boundsCenter, radius: bounds.boundsCenter.x - circleLineWidth / 2 - (circleBackgroudLineWidth - circleLineWidth) / 2, startAngle: -(.pi / 2), endAngle: -(.pi / 2) + .pi * 2, clockwise: true).cgPath
        layer.addSublayer(circleLayer)
    }
    
    // Start the animations for the progress indicator
    private func startAnimating() {
        if layer.animation(forKey: "rotation") == nil {
            startStrokeAnimation()
            startRotatingAnimation()
        }
    }
    
    // Rotate the progress indicator continuously
    private func startRotatingAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 2.2
        rotation.isCumulative = true
        rotation.isAdditive = true
        rotation.repeatCount = .infinity
        layer.add(rotation, forKey: "rotation")
    }
    
    // Animate the stroke of the circle layer to simulate progress
    private func startStrokeAnimation() {
        let easeInOutSineTimingFunc = CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1.0)
        let progress: CGFloat = maxStrokeLength
        let endFromValue: CGFloat = circleLayer.strokeEnd
        let endToValue: CGFloat = endFromValue + progress
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = endFromValue
        strokeEnd.toValue = endToValue
        strokeEnd.duration = 0.5
        strokeEnd.fillMode = CAMediaTimingFillMode.forwards
        strokeEnd.timingFunction = easeInOutSineTimingFunc
        strokeEnd.beginTime = 0.1
        strokeEnd.isRemovedOnCompletion = false
        let startFromValue: CGFloat = circleLayer.strokeStart
        let startToValue: CGFloat = abs(endToValue - minStrokeLength)
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.fromValue = startFromValue
        strokeStart.toValue = startToValue
        strokeStart.duration = 0.4
        strokeStart.fillMode = CAMediaTimingFillMode.forwards
        strokeStart.timingFunction = easeInOutSineTimingFunc
        strokeStart.beginTime = strokeEnd.beginTime + strokeEnd.duration + 0.2
        strokeStart.isRemovedOnCompletion = false
        let pathAnim = CAAnimationGroup()
        pathAnim.animations = [strokeEnd, strokeStart]
        pathAnim.duration = strokeStart.beginTime + strokeStart.duration
        pathAnim.fillMode = CAMediaTimingFillMode.forwards
        pathAnim.isRemovedOnCompletion = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if self.circleLayer.animation(forKey: "stroke") != nil {
                // Apply a rotation transform to the circle layer upon completion of the stroke animation
                self.circleLayer.transform = CATransform3DRotate(self.circleLayer.transform, .pi * 2 * progress, 0, 0, 1)
                // Remove the stroke animation and start a new one
                self.circleLayer.removeAnimation(forKey: "stroke")
                self.startStrokeAnimation()
            }
        }
        circleLayer.add(pathAnim, forKey: "stroke")
        CATransaction.commit()
    }
    
    // Stop the animations and reset the circle layers
    private func stopAnimating() {
        circleLayer.removeAllAnimations()
        layer.removeAllAnimations()
        circleLayer.transform = CATransform3DIdentity
        layer.transform = CATransform3DIdentity
        
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0
    }
}

// Extension to calculate the center point of a CGRect
extension CGRect {
    var boundsCenter: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}
