//
//  ViewController.swift
//  Project21
//
//  Created by Dillon McElhinney on 8/18/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Register",
                            style: .plain,
                            target: self,
                            action: #selector(registerLocal))

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Schedule",
                            style: .plain,
                            target: self,
                            action: #selector(scheduleInitial))
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }

    @objc func scheduleInitial() {
        scheduleLocal()
    }

    func scheduleLocal(_ timeInterval: TimeInterval = 5) {

        registerCategories()
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = """
        The early bird catches the worm,
        but the second mouse gets the cheese.
        """
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        //        var dateComponents = DateComponents()
        //        dateComponents.hour = 10
        //        dateComponents.minute = 30
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
        //                                                    repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                        repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        center.add(request)
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(identifier: "show",
                                        title: "Tell me more…",
                                        options: .foreground)
        let delay = UNNotificationAction(identifier: "delay",
                                         title: "Remind Me Later")
        let category = UNNotificationCategory(identifier: "alarm",
                                              actions: [show, delay],
                                              intentIdentifiers: [])

        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let customData = userInfo["customData"] as? String {

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                presentAlert(title: "Default Action",
                             message: "Looks like you just tapped on the notification")
            case "show":
                presentAlert(title: "Show Action",
                             message: "Looks like you tapped on the 'Tell Me More' button")
            case "delay":
                scheduleLocal(10)
            default:
                break
            }
        }

        completionHandler()
    }

    func presentAlert(title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel)
        alertController.addAction(okay)

        present(alertController, animated: true)
    }
}

