//
//  BroadcastViewController.swift
//  ThingsBeaconDebug
//
//  Created by Sergey Korobin on 12.05.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AVFoundation

class BroadcastViewController: UIViewController {
    
    var broadcasting: Bool = false
    var beacon: CLBeaconRegion?
    var peripheralManager: CBPeripheralManager?
    let speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var broadcastButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareBeaconRegion()
    }
    deinit
    {
        print("deinit")
        self.beacon = nil
        self.peripheralManager = nil
    }
    
    func prepareBeaconRegion() {
        
        let uuid = UUID(uuidString: "F84A9451-DD4A-48A6-947E-608F76ED5393")!
        let major: CLBeaconMajorValue = CLBeaconMajorValue(101)
        let minor: CLBeaconMinorValue = CLBeaconMinorValue(2)
        
        beacon = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: "korobo.beacon")
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    @IBAction func broadcastModeChange(_ sender: UIButton) {
        
        func buttonTitleState() -> String {
            return (self.broadcasting) ? "Start" : "Stop" + " Broadcast"
        }
        
        func labelTextStatus() -> String {
            return (self.broadcasting) ? "Not Broadcast" : "Broadcasting..."
        }
        
        let state: CBManagerState = self.peripheralManager!.state
        
        if (state == .poweredOff && !CLLocationManager.locationServicesEnabled() && !self.broadcasting){
            let utterance = AVSpeechUtterance(string: "Включите Bluetooth и службы геолокации.")
            utterance.rate = 0.5
            // pitch and volume
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            let alert: UIAlertController = UIAlertController(title: "Bluetooth and Geolocation OFF", message: "Please power on your Bluetooth and Geolocation tools!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: {
                self.speechSynthesizer.speak(utterance)
            })
            // озвучка алерта о том, что блютуз выключен
        } else if (state == .poweredOff) {
            let utterance = AVSpeechUtterance(string: "Включите Bluetooth.")
            utterance.rate = 0.5
            // pitch and volume
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            let alert: UIAlertController = UIAlertController(title: "Bluetooth OFF", message: "Please power on your Bluetooth!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: {
                self.speechSynthesizer.speak(utterance)
            })
            
            // озвучка алерта о том, что службы геолокации выключены
        } else if !CLLocationManager.locationServicesEnabled() {
            let utterance = AVSpeechUtterance(string: "Включите службы геолокации.")
            utterance.rate = 0.5
            // pitch and volume
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            let alert: UIAlertController = UIAlertController(title: "Geolocation OFF", message: "Please power on your Geolocation!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: {
                self.speechSynthesizer.speak(utterance)
            })
        } else {
            
            sender.setTitle(buttonTitleState(), for: UIControlState.normal)
//            UIApplication.shared.isIdleTimerDisabled = true
            self.statusLabel.text = labelTextStatus()
            self.broadcasting = !self.broadcasting
            // start broadcasting
            smartBroadcasting(status: broadcasting)
            
        }
    
    }
    
    func smartBroadcasting(status: Bool)
    {
        if self.peripheralManager == nil {
            print("Found nil in peripheralManager!")
            return
        }
        
        if (!status) {
            print("*** STOP BROADCASTING ***")
            // выключаем постоянную работу экрана в процессе раздачи сигнала! Уведомить через аудио! FIXIT
            UIApplication.shared.isIdleTimerDisabled = false
            self.peripheralManager!.stopAdvertising()
            
            return
        }
        
        let state: CBManagerState = self.peripheralManager!.state
        
        if (state == .poweredOn) {
            
            let UUID:UUID = (self.beacon?.proximityUUID)!
            let serviceUUIDs: Array<CBUUID> = [CBUUID(nsuuid: UUID)]
            
            var peripheralData: Dictionary<String, Any> = self.beacon!.peripheralData(withMeasuredPower: nil)  as NSDictionary as! Dictionary<String, Any>
            peripheralData[CBAdvertisementDataLocalNameKey] = "iBeacon Demo"
            peripheralData[CBAdvertisementDataServiceUUIDsKey] = serviceUUIDs
            
            print("*** START BROADCASTING ***")
            // включаем постоянную работу экрана в процессе раздачи сигнала! Уведомить через аудио! FIXIT
            UIApplication.shared.isIdleTimerDisabled = true
            self.peripheralManager!.startAdvertising(peripheralData)
            runTimer()
        }
    }
    
    func runTimer() {
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BroadcastViewController.brightnessDecreaser), userInfo: nil, repeats: false)
    }
    
    @objc func brightnessDecreaser(){
        UIScreen.main.brightness = CGFloat(0.1)
    }
    
}

extension BroadcastViewController: CBPeripheralManagerDelegate
{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        let state: CBManagerState = peripheralManager!.state
        
        if state == .poweredOff {
            self.statusLabel.text = "Bluetooth Off"
            
            if self.broadcasting {
//                 switch off broadcasting
                self.broadcastModeChange(self.broadcastButton)
                print("sudenly bluetooth off")
            }
        }
        
        if state == .unsupported {
            self.statusLabel.text = "Unsupported Beacon device"
        }
        
        if state == .poweredOn {
            self.statusLabel.text = "Ready for broadcasting."
        }
    }
}
