//
//  AppDelegate.swift
//  Project2
//
//  Created by Dillon McElhinney on 5/31/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        askForNotificationPermission()

        scheduleDailyNotifications()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func askForNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, _) in
            if !granted {
                // TODO: - Occasionally ask the user if they've changed their mind?
            }
        }
    }

    func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()

        // Get rid of any old notifications
        center.removeAllPendingNotificationRequests()

        // Figure out what day of the week today is
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.weekday],
                                                     from: Date())
        guard let today = dateComponents.weekday else { return }

        // Get a set of all the other days
        let days = Set([1, 2, 3, 4, 5, 6, 7]).subtracting([today])

        // Build notifications for each of those days
        days.map(buildNotification)
            // And add them all to the notification center
            .forEach {
                center.add($0)
        }
    }

    func buildNotification(on weekday: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget to play"
        content.body = """
        You haven't played your game yet today!
        """
        content.sound = UNNotificationSound.default

        // Schedule for 8:30 pm
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 30
        dateComponents.weekday = weekday
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        return request
    }

}

