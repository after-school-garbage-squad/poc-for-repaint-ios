//
//  LocalNotification.swift
//  BLE test
//  
//  Created by shiron on 2023/05/10
//  
//

import UserNotifications

final class NotificationManager {
   static let instance: NotificationManager = NotificationManager()

   // 権限リクエスト
   func requestPermission() {
       UNUserNotificationCenter.current()
           .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
               print("Permission granted: \(granted)")
           }
   }

   // notificationの登録
    func sendNotification(title: String, body: String, interval: Double = 1) {
       let content = UNMutableNotificationContent()
       content.title = title
       content.body = body

       let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
       let request = UNNotificationRequest(identifier: "notification01", content: content, trigger: trigger)

       UNUserNotificationCenter.current().add(request)
   }
}

