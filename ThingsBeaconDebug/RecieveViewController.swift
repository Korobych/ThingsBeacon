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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        lookForBeacons()
//    }
    
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
            lookForBeacons()
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
            var newDistance = ""
            newDistance = prepareDistanceString(myBeacon: myBeacon)
            switch myBeacon.proximity {
            case .near, .immediate, .far:
                if notifyCounter % 4  == 0 {
//                    newDistance = prepareDistanceString(myBeacon: myBeacon)
//                    let utterance = AVSpeechUtterance(string: "\(String(format: "%.2f", myBeacon.accuracy)) метра")
                    let utterance = AVSpeechUtterance(string: "\(newDistance)")
                    utterance.rate = 0.5
                    // pitch and volume
                    utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
                    self.speechSynthesizer.speak(utterance)
                }
                self.notifyCounter += 1
                self.beaconLostFlag = false
                self.proximityLabel.text = myBeacon.proximity.stringValue()
                // FIXIT
//                self.distanceLabel.text = "Расстояние: \(String(format: "%.2f", myBeacon.accuracy)) метров"
                self.distanceLabel.text = newDistance
                print(newDistance)
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
//                self.proximityLabel.text = myBeacon.proximity.stringValue()
                print("proximity - \(myBeacon.proximity.stringValue())")
                self.distanceLabel.text = "Маяк вне зоны доступа"
                break
            }
        }
       
    }
    
    func prepareDistanceString(myBeacon: CLBeacon) -> String {
        var distanceString = ""
        if myBeacon.accuracy < 1.0{
            let distRaw = String(format: "%.2f", myBeacon.accuracy)
            let cm = Int((distRaw as NSString).doubleValue * 100)
            switch distRaw.last{
            case "1":
                distanceString = "\(cm) сантиметр"
                return distanceString
            case "2", "3", "4":
                distanceString = "\(cm) сантиметра"
                return distanceString
            case "5", "6", "7", "8", "9", "0":
                distanceString = "\(cm) сантиметров"
                return distanceString
            default:
                // wtf
                print("\(distanceString) сантиметров")
                return distanceString
            }
        } else if myBeacon.accuracy < 10.0{
            let distRaw = String(format: "%.0f", myBeacon.accuracy)
            switch distRaw{
            case "1":
                distanceString = "\(distRaw) метр"
                return distanceString
            case "2", "3", "4":
                distanceString = "\(distRaw) метра"
                return distanceString
            case "5", "6", "7", "8", "9", "0":
                distanceString = "\(distRaw) метров"
                return distanceString
            default:
                // wtf
                print("\(distanceString) метров")
                return distanceString
            }
        } else if myBeacon.accuracy < 20.0{
            let distRaw = String(format: "%.0f", myBeacon.accuracy)
            return "\(distRaw) метров"
        } else {
            let distRaw = String(format: "%.0f", myBeacon.accuracy)
            switch distRaw.last{
            case "1":
                distanceString = "\(distRaw) метр"
                return distanceString
            case "2", "3", "4":
                distanceString = "\(distRaw) метра"
                return distanceString
            case "5", "6", "7", "8", "9", "0":
                distanceString = "\(distRaw) метров"
                return distanceString
            default:
                // wtf
                print("\(distanceString) метров")
                return distanceString
            }
        }
    }

}

extension CLProximity {
    
    func stringValue() -> String {
        switch rawValue {
        case 0: return "Неизвестно" //unknown
        case 1: return "Вплотную" // immediate
        case 2: return "Рядом" // near
        case 3: return "Далеко" // far
        default: return "невозможно определить" //can't determine
        }
    }
}
