//
//  RecieveViewController.swift
//  ThingsBeaconDebug
//
//  Created by Sergey Korobin on 12.05.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AVFoundation

class RecieveViewController: UIViewController {
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var location: CLLocationManager?
    var peripheralManager: CBPeripheralManager?
    // FIXIT Singletone
    let speechSynthesizer = AVSpeechSynthesizer()
    var notifyCounter = 0
    var beaconLostFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXIT Singletone
        location = CLLocationManager()
        location?.delegate = self
        location?.requestAlwaysAuthorization()
    }
    deinit
    {
        print("deinit")
        self.location = nil
        self.peripheralManager = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lookForBeacons()
    }
    
    func lookForBeacons() {
        let uuid = UUID(uuidString: "F84A9451-DD4A-48A6-947E-608F76ED5393")!
        
        let localBeaconRegion = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(101), minor: CLBeaconMinorValue(2), identifier: "korobo.beacon")
        // monitoring started
        print("*** ranging started ***")
        self.location?.stopRangingBeacons(in: localBeaconRegion)
        self.location?.startRangingBeacons(in: localBeaconRegion)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension RecieveViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        
        if status == .authorizedAlways{
            print("Always in usage") }
        else {
            if status == .authorizedWhenInUse{
                print("when in use")
            } else {
                if status == .denied {
                    print("denied")
                } else {
                    if status == .notDetermined {
                        print("not determined")
                    } else {
                        if status == .restricted {
                            print("restricted")
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        if region is CLBeaconRegion {
            print("didEnter region  " + region.identifier)
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        if beacons.count != 0{
            let myBeacon = beacons.first!
            
            switch myBeacon.proximity {
            case .near, .immediate, .far:
                if notifyCounter % 3  == 0 {
                    let utterance = AVSpeechUtterance(string: "\(String(format: "%.2f", myBeacon.accuracy)) метра")
                    utterance.rate = 0.5
                    // pitch and volume
                    utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
                    self.speechSynthesizer.speak(utterance)
                }
                self.notifyCounter += 1
                self.beaconLostFlag = false
        
                self.proximityLabel.text = myBeacon.proximity.stringValue()
                self.distanceLabel.text = "Distance:  \(String(format: "%.2f", myBeacon.accuracy))m"
                break
                
            case .unknown:
                if !self.beaconLostFlag{
                    let utterance = AVSpeechUtterance(string: "Цель вне зоны доступа.")
                    utterance.rate = 0.5
                    // pitch and volume
                    utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
                    self.speechSynthesizer.speak(utterance)
                    self.beaconLostFlag = true
                }
                self.proximityLabel.text = myBeacon.proximity.stringValue()
                self.distanceLabel.text = "Beacon out of range"
                break
            }
        }
       
    }
    
    
    
    
    
}

extension CLProximity {
    
    func stringValue() -> String {
        switch rawValue {
        case 0: return "unknown"
        case 1: return "immediate"
        case 2: return "near"
        case 3: return "far"
        default: return "can't determine"
        }
    }
}
