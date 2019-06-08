//
//  ViewController.swift
//  NLSpinnerDemo
//
//  Created by Nathan Lapierre on 2017-03-13.
//
//

import Cocoa
import NLSpinner

class ViewController: NSViewController {
    
    @IBOutlet weak var spinner : NLSpinner!
    @IBOutlet weak var startStopButton : NSButton!
    @IBOutlet weak var colorButton : NSButton!
    @IBOutlet weak var speedButton : NSButton!
    @IBOutlet weak var showWhenStopped : NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.startAnimation()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    //start and stopping is simple...
    @IBAction func startStopSpinner(_ sender:AnyObject?) {
        if (spinner.isAnimating) {
            spinner.stopAnimation()

            changeShowWhenStopped(self)
            startStopButton.title = "Start"
            colorButton.isEnabled = false
            speedButton.isEnabled = false
        } else {
            spinner.startAnimation()
            
            startStopButton.title = "Stop"
            colorButton.isEnabled = true
            speedButton.isEnabled = true
        }
    }
    
    //...so is changing the color
    @IBAction func changeSpinnerColor(_ sender:AnyObject?) {
        spinner.foregroundColor = NSColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
    
    //the speed is set by tickDelay, which is the delay in seconds before advancing the highlighted fin
    @IBAction func changeSpinnerSpeed(_ sender:AnyObject?) {
        if (spinner.tickDelay == 0.05) {
            spinner.tickDelay = 0.01
        } else {
            spinner.tickDelay = 0.05
        }
    }
    
    //can optionally hide spinner when stopped, otherwise it fades slightly
    @IBAction func changeShowWhenStopped(_ sender:AnyObject?) {
        if (showWhenStopped.state == NSControl.StateValue.on) {
            spinner.isDisplayedWhenStopped = true
        } else {
            spinner.isDisplayedWhenStopped = false
        }
    }

}

