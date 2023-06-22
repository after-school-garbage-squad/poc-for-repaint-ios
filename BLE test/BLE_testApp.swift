//
//  BLE_testApp.swift
//  BLE test
//
//  Created by shiron on 2023/05/04.
//

import SwiftUI

@main
struct BLE_testApp: App {
    var body: some Scene {
        WindowGroup {
            
            Button(action: {NotificationManager.instance.sendNotification(title: "title", body: "body", interval: 5)}){
                Text("Notification")
            }
            
            TabView{
                BeaconView().tabItem {
                    Text("Beacon")
                }
                BluetoothView().tabItem {
                    Text("Bluetooth")
                }
            }
        }
    }
}
