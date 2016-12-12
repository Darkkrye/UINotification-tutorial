//
//  AppDelegate.swift
//  NotificationsUI
//
//  Created by Pranjal Satija on 9/12/16.
//  Copyright © 2016 Pranjal Satija. All rights reserved.
//

import UIKit
import UserNotifications

// https://www.appcoda.com/ios10-user-notifications-guide/
// https://blog.pusher.com/how-to-send-ios-10-notifications-using-the-push-notifications-api/

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        })
        
        let action = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let act = UNNotificationAction(identifier: "schedule", title: "Schedule", options: [])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [action, act], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }
    
    func scheduleNotification(at date: Date, showName: String, imageURL: String) {
        UNUserNotificationCenter.current().delegate = self
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, era: nil, year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: components.second, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Tutorial Reminder"
        content.body = "Just a reminder to read your tutorial over at appcoda.com"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "myCategory"
        
        
        if let url = URL(string: imageURL), let data = NSData(contentsOf: url) {
            if let att = UNNotificationAttachment.create(imageFileIdentifier: showName, data: data as Data, options: nil, baseURL: imageURL) {
                content.attachments = [att]
            } else {
                print("The attachment was not loaded")
            }
        } else {
            print("The attachment was not created")
        }
        
        /*let url = URL(string: imageURL)!
        do {
            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachment was not loaded")
        }*/
        
        let request = UNNotificationRequest(identifier: showName, content: content, trigger: trigger)
        
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("ERROR : \(error)")
            }
        })
    }
    
    func scheduleNotificationEveryWeek(showName: String, attachment: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Scheduled notification"
        content.body = "This is your scheduled notification"
        content.sound = UNNotificationSound.default()
        
        if let url = URL(string: attachment), let data = NSData(contentsOf: url) {
            if let att = UNNotificationAttachment.create(imageFileIdentifier: showName, data: data as Data, options: nil, baseURL: attachment) {
                content.attachments = [att]
            } else {
                print("The attachment was not loaded")
            }
        } else {
            print("The attachment was not created")
        }
        
        /*if let path = Bundle.main.path(forResource: "logo", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            print(url.absoluteString)
            
            /*do {
                let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("The attachment was not loaded")
            }*/
        }
        
        let url = URL(fileURLWithPath: attachment)
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachment was not loaded")
        }*/
        
        let request = UNNotificationRequest(identifier: "Scheduled \(showName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("ERROR : \(error)")
            }
        })
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Test delegate")
        
        let attachment = response.notification.request.content.attachments.first
        
        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeInterval: 60, since: Date())
            
            scheduleNotification(at: newDate, showName: response.notification.request.identifier, imageURL: attachment!.url.absoluteString)
        } else if response.actionIdentifier == "schedule" {
            print("Schedule")
            print(response.notification.request.identifier)
            print(attachment!.identifier)
            self.scheduleNotificationEveryWeek(showName: response.notification.request.identifier, attachment: attachment!.identifier)
        }
        
        completionHandler()
    }
}

extension UNNotificationAttachment {
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?, baseURL: String) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            
            let fileURL = tmpSubFolderURL.appendingPathComponent("\(imageFileIdentifier).png")
            
            try data.write(to: fileURL)
            
            let imageAttachment = try UNNotificationAttachment.init(identifier: baseURL, url: fileURL, options: options)
            
            return imageAttachment
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
