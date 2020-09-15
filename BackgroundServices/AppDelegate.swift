//
//  AppDelegate.swift
//  BackgroundServices
//
//  Created by Lyle Jover on 9/15/20.
//  Copyright © 2020 craftycoders.io. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "craftycoders.io.BackgroundServices.testBGFetch", using: DispatchQueue.global()) { task in
            self.handleAppRefreshTask(task)
        }
        return true
    }
        
    func handleAppRefreshTask(_ task: BGTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            self.appRefreshOperation()
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }

        scheduleAppRefresh()
    }
    
    func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "craftycoders.io.BackgroundServices.testBGFetch")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 5)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
    
    func appRefreshOperation(){
        print("App refresh operation")
        
        //Run the app using a real device, hit pause then run this code below in the debugger. 
        //e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"craftycoders.io.BackgroundServices.testBGFetch"]
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

