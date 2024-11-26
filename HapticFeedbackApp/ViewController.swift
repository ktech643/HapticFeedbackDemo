//
//  ViewController.swift
//  HapticFeedbackApp
//
//  Created by Jahan on 16/11/2024.
//

import UIKit

class ViewController: UIViewController {
    
    private var dot: UIView!
    private let dotSize: CGFloat = 50.0 // Size of the dot
    private let maxDistance: CGFloat = 1000.0 // Maximum distance for feedback
    private var hapticGenerator: UIImpactFeedbackGenerator?
    
    private var screenBounds: CGRect {
        return self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // Create the dot
        dot = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        dot.backgroundColor = .red
        dot.layer.cornerRadius = dotSize / 2
        self.view.addSubview(dot)
        
        placeDotRandomly()
        addTouchGesture()
    }
    
    // Places the dot at a random position on the screen
    private func placeDotRandomly() {
        let maxX = screenBounds.width - dotSize
        let maxY = screenBounds.height - dotSize
        let randomX = CGFloat.random(in: 0...maxX)
        let randomY = CGFloat.random(in: 0...maxY)
        dot.center = CGPoint(x: randomX, y: randomY)
    }
    
    private func addTouchGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: self.view)
        
        switch gesture.state {
        case .changed:
            provideProximityFeedback(touchPoint: touchPoint)
        case .ended:
            // Reset the dot if the user reached it
            if isTouchOnDot(touchPoint: touchPoint) {
                triggerHapticClick()
                placeDotRandomly()
            }
        default:
            break
        }
    }
    
    // Checks if the user's touch is on the dot
    private func isTouchOnDot(touchPoint: CGPoint) -> Bool {
        let distance = hypot(dot.center.x - touchPoint.x, dot.center.y - touchPoint.y)
        return distance <= dotSize / 2
    }
    
    private func provideProximityFeedback(touchPoint: CGPoint) {
        let distance = hypot(dot.center.x - touchPoint.x, dot.center.y - touchPoint.y)
        
        // Calculate intensity: closer to the dot results in higher intensity
        let intensity = max(0, 1.0 - (distance / maxDistance))
        
        if intensity > 0 { // Only trigger feedback if within max distance
            if hapticGenerator == nil {
                hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
                hapticGenerator?.prepare()
            }
            hapticGenerator?.impactOccurred(intensity: intensity)
        }
    }
    
    private func triggerHapticClick() {
        // Use a heavy style for a "hard" haptic pattern
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        
        // Generate a sequence of intense haptic feedback
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred() // First strong feedback
        
        // Add quick repetitions for more impact
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Pause slightly for emphasis, then a final heavy impact
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        hapticGenerator = nil // Reset haptic generator after a successful touch
    }
}
