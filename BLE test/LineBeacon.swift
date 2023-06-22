//
//  LineBeacon.swift
//  BLE test
//  
//  Created by shiron on 2023/06/22
//  
//
/*
import SwiftUI
import CoreBluetooth

struct LineBeacon: View {
    
    @ObservedObject var beaconScanner = BeaconScanner()
    
    var body: some View {
        VStack {
            Text("LINE Beacon Advertising")
            
        }
        .onDisappear {
            // Stop timer when view disappears
        }
    }
}


class BeaconScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    
    let serviceUUID = CBUUID(string: "bbb824a0-f91e-11e4-a046-0002a5d5c51b")
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            // central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            // Bluetooth is not available or powered on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (serviceUUID, data) in serviceData {
                if serviceUUID.uuidString == "FE6F" {
                    let frameType = data[0]
                    if frameType == 0x02 {
                        let hwid = data.subdata(in: 1..<6)
                        let hwidString = hwid.map { String(format: "%02X", $0) }.joined()
                        NotificationManager.instance.sendNotification(title: "LINE Beacon", body: hwidString)
                        print("LINE Simple Beacon HWID: \(hwidString)")
                    }
                }
            }
        }
    }
}
*/
