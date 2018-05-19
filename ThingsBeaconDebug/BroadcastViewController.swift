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
    @IBOutlet weak var animatedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animatedButton.layer.cornerRadius = animatedButton.frame.width / 1.65
        animatedButton.clipsToBounds = true
        // перенести в другое место
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
            return (self.broadcasting) ? "Начать" : "Остановить" + " раздачу"
        }
        
        func labelTextStatus() -> String {
            return (self.broadcasting) ? "Маяк ожидает включения" : "Идет раздача сигнала..."
        }
        
        let state: CBManagerState = self.peripheralManager!.state
        
        if (state == .poweredOff && !CLLocationManager.locationServicesEnabled() && !self.broadcasting){
            let utterance = AVSpeechUtterance(string: "Включите Bluetooth и службы геолокации.")
            utterance.rate = 0.5
            // pitch and volume
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            let alert: UIAlertController = UIAlertController(title: "Bluetooth и службы геолокации выключены!", message: "Пожалуйста, включите Bluetooth и службы геолокации!", preferredStyle: .alert)
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
            
            let alert: UIAlertController = UIAlertController(title: "Блютуз выключен", message: "Пожалуйста, включите службы Bluetooth!", preferredStyle: .alert)
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
            
            let alert: UIAlertController = UIAlertController(title: "Службы геолокации выключены", message: "Пожалуйста, включите службы геолокации!", preferredStyle: .alert)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: {
                self.speechSynthesizer.speak(utterance)
            })
        } else {
            
            sender.setTitle(buttonTitleState(), for: UIControlState.normal)
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
            self.animatedButton.layer.removeAllAnimations()
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
            puslingButton(button: self.animatedButton)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func runTimer() {
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BroadcastViewController.brightnessDecreaser), userInfo: nil, repeats: false)
    }
    
    @objc func brightnessDecreaser(){
        // FIXIT  animate
        UIScreen.main.brightness = CGFloat(0.1)
    }
    
    func puslingButton(button: UIButton){
        button.isUserInteractionEnabled = false
        button.isEnabled = true
        
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.25
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.7
        animationGroup.repeatCount = .greatestFiniteMagnitude
        animationGroup.animations = [pulse1]
        
        button.layer.add(animationGroup, forKey: "pulse")
    }
    
}

extension BroadcastViewController: CBPeripheralManagerDelegate
{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        let state: CBManagerState = peripheralManager!.state
        
        if state == .poweredOff {
            self.statusLabel.text = "Bluetooth выключен"
            
            if self.broadcasting {
//                 switch off broadcasting
                self.broadcastModeChange(self.broadcastButton)
                print("sudenly bluetooth off")
            }
        }
        
        if state == .unsupported {
            self.statusLabel.text = "Устройство не поддерживается"
        }
        
        if state == .poweredOn {
            self.statusLabel.text = "Готов к раздаче сигнала!"
        }
    }
}
