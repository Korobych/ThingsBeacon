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
    
    @IBOutlet weak var broadcastButton: UIButton!
    @IBOutlet weak var animatedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animatedButton.layer.cornerRadius = animatedButton.frame.width / 1.65
        animatedButton.clipsToBounds = true
        broadcastButton.isHidden = true
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
            // quickfix
            self.animatedButton.layer.removeAllAnimations()
            let utterance = AVSpeechUtterance(string: "Включите Bluetooth.")
            utterance.rate = 0.5
            // pitch and volume
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            let alert: UIAlertController = UIAlertController(title: "Bluetooth выключен", message: "Пожалуйста, включите службы Bluetooth!", preferredStyle: .alert)
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
            // постоянное поддержание приложения с включенным экраном + озвучка начала раздачи сигнала
            let utterance = AVSpeechUtterance(string: "Раздача сигнала успешно начата!")
            utterance.rate = 0.5
            utterance.preUtteranceDelay = 4.0
            // pitch and volume
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            self.speechSynthesizer.speak(utterance)
            UIApplication.shared.isIdleTimerDisabled = true
            self.peripheralManager!.startAdvertising(peripheralData)
            // FIXIT Screen brightness
//            runTimer()
            puslingButton(button: self.animatedButton)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func runTimer() {
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BroadcastViewController.brightnessDecreaser), userInfo: nil, repeats: false)
    }
    
    // FIXIT  animate
    @objc func brightnessDecreaser(){
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
            print("Bluetooth выключен")
            self.broadcastModeChange(self.broadcastButton)
        }
        
        if state == .unsupported {
            print("Устройство не поддерживается")
        }
        
        if state == .poweredOn {
            print("Готов к раздаче сигнала!")
            self.broadcastModeChange(self.broadcastButton)
        }
    }
}
