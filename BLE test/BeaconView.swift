//
//  BeaconView.swift
//  BLE test
//  
//  Created by shiron on 2023/05/09
//  
//

import SwiftUI
import CoreLocation
import UserNotifications


struct BeaconView: View {
    @ObservedObject var beaconManager = BeaconManager()
    var body: some View {
        VStack {
            Text("Beacon")
            Button(action: {
                beaconManager.startMyMonitoring()
            }){
                Text("Start")
            }
            
        }
    }
}

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    let constraint = CLBeaconIdentityConstraint(uuid: UUID(uuidString: "d0d2ce24-9efc-11e5-82c4-1c6a7a17ef38")!)
    
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var beaconUuids: NSMutableArray!
    var beaconDetails: NSMutableArray!
    
    override init() {
        super.init()
        
        NotificationManager.instance.requestPermission()
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = 1
        
        myLocationManager.allowsBackgroundLocationUpdates = true
        
        myLocationManager.pausesLocationUpdatesAutomatically = false
        
        let status = myLocationManager.authorizationStatus
        print("CLAuthorizedStatus: \(status.rawValue)");
        if(status == .notDetermined) {
            myLocationManager.requestAlwaysAuthorization()
        }
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        
        
        myLocationManager.startUpdatingLocation()
        
        
        myLocationManager.requestWhenInUseAuthorization()
    }
    
    public func startMyMonitoring() {
        let identifierStr: String = "abcde1"
        myBeaconRegion = CLBeaconRegion(uuid: constraint.uuid, identifier: identifierStr)
        myBeaconRegion.notifyEntryStateOnDisplay = false
        myBeaconRegion.notifyOnEntry = true
        myBeaconRegion.notifyOnExit = true
        myLocationManager.startMonitoring(for: myBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus");
        switch (status) {
        case .notDetermined:
            print("not determined")
            break
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorizedAlways:
            print("authorizedAlways")
            startMyMonitoring()
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            startMyMonitoring()
            break
        @unknown default:
            print("def")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region);
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch (state) {
        case .inside:
            print("iBeacon inside");
            // manager.startRangingBeacons(satisfying: constraint)
            NotificationManager.instance.sendNotification(title: "inside", body: region.identifier)
            break;
        case .outside:
            print("iBeacon outside")
            NotificationManager.instance.sendNotification(title: "outside", body: region.identifier)
            break;
        case .unknown:
            print("iBeacon unknown")
            break;
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        if(beacons.count > 0){
            for i in 0 ..< beacons.count {
                let beacon = beacons[i]
                let beaconUUID = beacon.uuid;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                var proximity = ""
                switch (beacon.proximity) {
                case CLProximity.unknown :
                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    break
                case CLProximity.far:
                    print("Proximity: Far");
                    proximity = "Far"
                    break
                case CLProximity.near:
                    print("Proximity: Near");
                    proximity = "Near"
                    break
                case CLProximity.immediate:
                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    break
                @unknown default:
                    break
                }
                beaconUuids.add(beaconUUID.uuidString)
                var myBeaconDetails = "Major: \(majorID) "
                myBeaconDetails += "Minor: \(minorID) "
                myBeaconDetails += "Proximity:\(proximity) "
                myBeaconDetails += "RSSI:\(rssi)"
                print(myBeaconDetails)
                beaconDetails.add(myBeaconDetails)
                NotificationManager.instance.sendNotification(title: proximity, body: myBeaconDetails)
                // label1.text = proximity
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: iBeacon found");
        manager.startRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: iBeacon lost");
        manager.stopRangingBeacons(satisfying: constraint)
    }

}
