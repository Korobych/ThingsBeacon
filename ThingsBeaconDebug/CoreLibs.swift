//
//  CoreLocationsPlusPeripheral.swift
//  ThingsBeaconDebug
//
//  Created by Sergey Korobin on 18.05.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import CoreLocation
import CoreBluetooth
import AVFoundation

class CoreLibs{
    static let sharedInstance = CoreLibs()
    
    var peripheralManager: CBPeripheralManager?
//    let speechSynthesizer = AVSpeechSynthesizer()
    var locationManager: CLLocationManager?
    
    private init() {
//        self.locationManager = CLLocationManager()
//        self.locationManager?.requestAlwaysAuthorization()
    }
    
    /// Preparing ios device broadcast signals as iBeacon
    func prepareBeaconRegion() {
        
        let uuid = UUID(uuidString: "F84A9451-DD4A-48A6-947E-608F76ED5393")!
        let major: CLBeaconMajorValue = CLBeaconMajorValue(101)
        let minor: CLBeaconMinorValue = CLBeaconMinorValue(2)
        
        let beacon = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: "korobo.beacon")
//        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    /// Preparing ios device for ranging nearby iBeacons
    func lookForBeacons() {
        let uuid = UUID(uuidString: "F84A9451-DD4A-48A6-947E-608F76ED5393")!
        
        let localBeaconRegion = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(101), minor: CLBeaconMinorValue(2), identifier: "korobo.beacon")
        print("*** ranging started ***")
        self.locationManager?.stopRangingBeacons(in: localBeaconRegion)
        self.locationManager?.startRangingBeacons(in: localBeaconRegion)
    }
}
