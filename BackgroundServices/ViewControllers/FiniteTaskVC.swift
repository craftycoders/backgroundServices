//
//  FiniteTaskVC.swift
//  BackgroundServices
//
//  Created by Lyle Jover on 9/15/20.
//  Copyright © 2020 craftycoders.io. All rights reserved.
//

import UIKit

class FiniteTaskVC: UIViewController {
  
    var previous = NSDecimalNumber.one
    var current = NSDecimalNumber.one
    var position: UInt = 1
    var updateTimer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    @IBOutlet var resultsLabel: UILabel!


    @IBAction func didTapPlayPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            resetCalculation()
            updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,
                                             selector: #selector(calculateNextNumber), userInfo: nil, repeats: true)
            registerBackgroundTask()

        } else {
            updateTimer?.invalidate()
            updateTimer = nil
            if backgroundTask != .invalid {
              endBackgroundTask()
            }
        }
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      NotificationCenter.default
        .addObserver(self, selector: #selector(reinstateBackgroundTask),
                     name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self)
    }

  
    @objc func calculateNextNumber() {
        let result = current.adding(previous)

        let bigNumber = NSDecimalNumber(mantissa: 1, exponent: 40, isNegative: false)
        if result.compare(bigNumber) == .orderedAscending {
          previous = current
          current = result
          position += 1
        } else {
          // This is just too much.... Start over.
          resetCalculation()
        }

        let resultsMessage = "Position \(position) = \(current)"
        switch UIApplication.shared.applicationState {
          case .active:
            resultsLabel.text = resultsMessage
          case .background:
            print("App is backgrounded. Next number = \(resultsMessage)")
            print("Background time remaining = " +
            "\(UIApplication.shared.backgroundTimeRemaining) seconds")
          case .inactive:
            break
        @unknown default:
            break
        }
    }

    func resetCalculation() {
        previous = .one
        current = .one
        position = 1
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
      
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    @objc func reinstateBackgroundTask() {
      if updateTimer != nil && backgroundTask ==  .invalid {
        registerBackgroundTask()
      }
    }
}
