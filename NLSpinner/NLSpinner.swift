//
//  NLSpinner.swift
//  NLSpinner
//
//  Created by Nathan Lapierre on 2017-03-13.
//
//

import Foundation

open class NLSpinner : NSView {
    
    private var finColors = [NSColor]()
    private var position: Int = 0
    private var isFadingOut: Bool = false
    private var animationTimer: Timer!
    private var startTime : NSDate = NSDate()
    
    //open library properties
    open private(set) var isAnimating: Bool = false
    open var numberOfFins: Int = 12
    open var isDisplayedWhenStopped: Bool = true {
        didSet {
            self.needsDisplay = true
        }
    }
    open var foregroundColor: NSColor! = NSColor.black
    open var backgroundColor: NSColor! = NSColor.clear
    open var tickDelay: Double = 0.05
    open var frameTime: Double = 0.032 //30FPS Default (0.032 seconds/frame)

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        for _ in 0..<numberOfFins {
            finColors.append(foregroundColor)
        }
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        //check if we need to show at all
        if (!isAnimating && !isDisplayedWhenStopped) {
            NSColor.clear.set()
            NSBezierPath.fill(self.bounds)
        } else {
        
            var maxSize: CGFloat = bounds.size.height
            if bounds.size.width <= maxSize {
                maxSize = bounds.size.width
            }
            
            backgroundColor.set()
            NSBezierPath.fill(self.bounds)
            
            let currentContext: CGContext = NSGraphicsContext.current!.cgContext
            NSGraphicsContext.saveGraphicsState()
            
            //draw fins
            currentContext.translateBy(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
            let path = NSBezierPath()
            path.lineWidth = CGFloat(0.07 * maxSize)
            path.lineCapStyle = NSBezierPath.LineCapStyle.round
            path.move(to: NSMakePoint(0, CGFloat(0.25 * maxSize)))
            path.line(to: NSMakePoint(0, CGFloat(0.45 * maxSize)))
            for i in 0..<finColors.count {
                if self.isAnimating {
                    finColors[i].set()
                }
                else {
                    foregroundColor.withAlphaComponent(CGFloat(0.2)).set()
                }
                path.stroke()
                currentContext.rotate(by: CGFloat(Double.pi * 2 / Double(finColors.count)))
            }
            
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    
    open func startAnimation() {
        if self.isAnimating && !isFadingOut {
            return
        }
        startTime = NSDate()
        self.startAnimationTimer()
    }
    open func stopAnimation() {
        isFadingOut = true
    }

    //update animation
    @objc func updateFrame(_ timer: Timer) {
        
        //move position every tickDelay seconds
        if (startTime.timeIntervalSinceNow <= 0 - abs(tickDelay)) {
            if position > 0 {
                position -= 1
            }
            else {
                position = finColors.count - 1
            }
            startTime = NSDate()
        }
        
        //fade trailing fins
        let minAlpha: CGFloat = CGFloat(0.2)
        for i in 0..<finColors.count {
            var newAlpha: CGFloat = finColors[i].alphaComponent
            newAlpha *= CGFloat(0.9) // fade by this amount
            if newAlpha < minAlpha {
                newAlpha = minAlpha
            }
            finColors[i] = foregroundColor.withAlphaComponent(newAlpha)
        }
        
        //is whole spinner fading out?
        if isFadingOut {
            var done: Bool = true
            for i in 0..<finColors.count {
                if abs(finColors[i].alphaComponent - minAlpha) > 0.01 && isDisplayedWhenStopped {
                    done = false
                    break
                }
            }
            if done {
                self.stopAnimationTimer()
            }
        } else {
            finColors[position] = foregroundColor
        }
        self.needsDisplay = true
    }
    
    private func startAnimationTimer() {
        stopAnimationTimer()
        isAnimating = true
        isFadingOut = false
        position = 1
        animationTimer = Timer(timeInterval: frameTime, target: self, selector: #selector(self.updateFrame), userInfo: nil, repeats: true)
        RunLoop.current.add(animationTimer, forMode: RunLoop.Mode.common)
        RunLoop.current.add(animationTimer, forMode: RunLoop.Mode.default)
        RunLoop.current.add(animationTimer, forMode: RunLoop.Mode.eventTracking)
    }
    private func stopAnimationTimer() {
        self.isAnimating = false
        isFadingOut = false
        if animationTimer != nil {
            // we were using timer-based animation
            animationTimer.invalidate()
            animationTimer = nil
        }
    }
}
