//
//  ContentView.swift
//  BLE test
//
//  Created by shiron on 2023/05/04.
//

import SwiftUI
import CoreBluetooth

struct BluetoothView: View {
    
    @ObservedObject var bluetoothManager = BluetoothManager()
    
    var body: some View {
        VStack {
            Text("Bluetooth Broadcasting and Scanning")
            
            Button(action: {
                bluetoothManager.isUseFilter = !bluetoothManager.isUseFilter
            }){
                if(bluetoothManager.isUseFilter){
                    Text("フィルターを使用中")
                }else{
                    Text("全探索中")
                }
            }
            Button(action:{
                bluetoothManager.scannedPeripherals = []
            }){
                Text("履歴を削除")
            }
            
            NavigationView{
                List(bluetoothManager.scannedPeripherals, id: \.self) { peripheral in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(peripheral.name ?? "Unknown")").font(.headline)
                        Text("Identifier: \(peripheral.identifier.uuidString)")
                        Text("State: \(peripheral.state.rawValue)")
                        Text("Services:")
                        ForEach(peripheral.services ?? [], id: \.uuid) { service in
                            Text("- \(service.uuid.uuidString)")
                            Text("    Characteristics:")
                            ForEach(service.characteristics ?? [], id: \.uuid) { characteristic in
                                Text("    - \(characteristic.uuid.uuidString)")
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            // Stop timer when view disappears
            bluetoothManager.timer?.invalidate()
            bluetoothManager.timer = nil
        }
    }
}


class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    @Published public var scannedPeripherals: [CBPeripheral] = []
    var timer: Timer?
    
    let serviceUUIDs = [CBUUID(string: "FE6F")]
    
    @Published public var isUseFilter = true
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Start timer to automatically broadcast and scan every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            // self.startBroadcasting()
            self.startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Add discovered peripheral to scannedPeripherals array
        if !scannedPeripherals.contains(peripheral) {
            scannedPeripherals.append(peripheral)
        }

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
        
        /*
        let url = URL(string: "http://192.168.0.171:3000/")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
        }.resume()
         */
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Bluetooth is ready to use
            startScanning()
        } else {
            // Bluetooth is not available
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            // Bluetooth is ready to use
            //startBroadcasting()
        } else {
            // Bluetooth is not available
        }
    }
    
    func startScanning() {
        // Start scanning for Bluetooth devices
        // print("scan")
        if(isUseFilter){
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
        }else{
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    /*
    func startBroadcasting() {
        print("Broadcast")
        // Start broadcasting Bluetooth signal
        let service = CBMutableService(type: serviceUUID, primary: true)
        let characteristicUUID = CBUUID(string: "AED269A3-CFFE-D059-6A7A-3F27AE3A3E67")
        let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.read, .write], value: nil, permissions: [.readable, .writeable])
        service.characteristics = [characteristic]
        peripheralManager.add(service)
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
    }
     */
    
}




/*

 /***
  scan
  ***/
 
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    @Published var devices = [CBPeripheral]()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !devices.contains(peripheral) {
            devices.append(peripheral)
            print("Found device: \(peripheral.name ?? "Unknown Device")")
        }
    }
}

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            List(bluetoothManager.devices, id: \.self) { device in
                Text(device.name ?? "Unknown Device")
            }
            .navigationTitle("Bluetooth Devices")
        }
        .onAppear {
            UIApplication.shared.beginBackgroundTask(withName: "Bluetooth Scan") { }
            DispatchQueue.main.async {
                self.bluetoothManager.centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
            let _ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
                DispatchQueue.main.async {
                    self.bluetoothManager.devices.removeAll()
                    let service = CBUUID(string: "AFD0FFA0-2A9E-41A9-B9DB-115A0E511DE4")
                    self.bluetoothManager.centralManager.scanForPeripherals(withServices: [service], options: nil)
                    print("Scan")
                }
            }
        }
    }
}
*/
