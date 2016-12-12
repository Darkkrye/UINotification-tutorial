//
//  ViewController.swift
//  NotificationsUI
//
//  Created by Pranjal Satija on 9/12/16.
//  Copyright © 2016 Pranjal Satija. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBAction func datePickerDidSelectNewDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleNotification(at: selectedDate, showName: "Test", imageURL: "https://www.appcoda.com/wp-content/uploads/2016/10/user-notification-image-1024x599.png")
    }
    
    @IBAction func stopScheduler(_ sender: Any) {
        let identifier = "Scheduled Test"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
